#!/usr/bin/env python3
"""Run the display switcher at startup and on physical monitor changes."""
import fcntl
import json
import os
from pathlib import Path
import select
import socket
import subprocess
import sys
import time

SWITCHER = Path(__file__).resolve().parents[1] / 'switch_display.sh'
POWER_DISPLAY = Path(__file__).resolve().with_name('display_power.py')
EVENTS = {b'monitoradded', b'monitoraddedv2', b'monitorremoved', b'monitorremovedv2'}


def topology():
    result = subprocess.run(['hyprctl', '-j', 'monitors', 'all'],
                            capture_output=True, text=True, check=True, timeout=5)
    # Disabled but still connected displays remain in this list. This prevents
    # manual Laptop Only / External Only changes from triggering auto-extend.
    return tuple(sorted((m['name'], m.get('description', ''))
                        for m in json.loads(result.stdout)
                        if not m['name'].startswith(('HEADLESS', 'WL-'))))


def watch(stream):
    pending = time.monotonic() + 0.8
    previous = None
    attempts = 0
    config_reloaded = False
    buffer = b''
    while True:
        timeout = None if pending is None else max(0, pending - time.monotonic())
        ready, _, _ = select.select([stream], [], [], timeout)
        if ready:
            data = stream.recv(65536)
            if not data:
                return  # Hyprland exited; the next session starts its own watcher.
            buffer += data
            while b'\n' in buffer:
                line, buffer = buffer.split(b'\n', 1)
                event = line.split(b'>>', 1)[0]
                if event in EVENTS or event == b'configreloaded':
                    pending = time.monotonic() + 0.8
                    attempts = 0
                    if event == b'configreloaded':
                        config_reloaded = True
        if pending is None or time.monotonic() < pending:
            continue
        pending = None
        try:
            current = topology()
            if current == previous and not config_reloaded:
                continue
            if current != previous:
                subprocess.run(['bash', str(SWITCHER), '--auto'], check=True, timeout=20)
            subprocess.run([sys.executable, str(POWER_DISPLAY)], check=True, timeout=20)
            # Retain the pre-apply topology: changes during application must still
            # be handled when their queued events are read.
            previous = current
            attempts = 0
            config_reloaded = False
            print('Configured displays: ' + ', '.join(name for name, _ in current), flush=True)
        except (OSError, ValueError, subprocess.SubprocessError) as error:
            print(f'Display hotplug: {error}', file=sys.stderr, flush=True)
            attempts += 1
            if attempts < 3:
                pending = time.monotonic() + 1


def main():
    signature = os.environ.get('HYPRLAND_INSTANCE_SIGNATURE')
    runtime = os.environ.get('XDG_RUNTIME_DIR')
    if not signature or not runtime:
        sys.exit('Display hotplug: run inside a Hyprland session.')
    session = Path(runtime) / 'hypr' / signature
    # One watcher per compositor session, even if launched manually twice.
    with (session / 'display-hotplug.lock').open('w') as lock:
        try:
            fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError:
            return
        with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as stream:
            stream.connect(str(session / '.socket2.sock'))
            watch(stream)


if __name__ == '__main__':
    main()
