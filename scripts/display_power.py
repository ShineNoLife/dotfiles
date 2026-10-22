#!/usr/bin/env python3
"""Apply laptop refresh policy without changing display layout or mirroring."""
import argparse
import fcntl
import json
import os
from pathlib import Path
import re
import subprocess
import sys
import time

SERVICE = 'org.freedesktop.UPower.PowerProfiles'
SERVICE_PATH = '/org/freedesktop/UPower/PowerProfiles'
MODE = re.compile(r'^(\d+)x(\d+)@([\d.]+)(?:Hz)?$')
# CMN N160JME-GTK: preserve its native clock/horizontal timing, extend vblank.
# Tested on this panel at 59.94 Hz and visually confirmed before persistence.
PANEL_60 = 'modeline 389.38 1920 1968 2000 2080 1200 1210 1216 3120 -hsync -vsync'


def command(args):
    return subprocess.check_output(args, text=True, timeout=8).strip()


def monitors():
    return json.loads(command(['hyprctl', '-j', 'monitors', 'all']))


def saving():
    try:
        result = command(['/usr/bin/busctl', '--system', '--timeout=5s', '--json=short',
                          'get-property', SERVICE, SERVICE_PATH, SERVICE, 'ActiveProfile'])
        return json.loads(result)['data'] == 'power-saver'
    except (OSError, ValueError, KeyError, subprocess.SubprocessError):
        # Do not change a display's mode if the power service is unavailable.
        return None


def select_mode(monitor, power_saver):
    modes = []
    for raw in monitor.get('availableModes', []):
        match = MODE.fullmatch(raw)
        if match:
            w, h, hz = match.groups()
            modes.append((int(w), int(h), float(hz)))
    if not modes:
        raise ValueError(f"No advertised modes for {monitor['name']}")
    best = max(modes, key=lambda m: (m[0] * m[1], m[2], m[0], m[1]))
    native = [m for m in modes if m[:2] == best[:2]]
    if power_saver:
        sixty = [m for m in native if abs(m[2] - 60) < 0.5]
        if sixty:
            best = min(sixty, key=lambda m: abs(m[2] - 60))
        elif (monitor.get('description', '').startswith('Chimei Innolux Corporation 0x1621 ')
              and best[:2] == (1920, 1200)):
            return PANEL_60, 1920, 1200, 60.0
        else:
            raise ValueError(f"60 Hz is not available on {monitor['name']}")
    return f'{best[0]}x{best[1]}@{best[2]:.3f}', *best


def monitor_rule(monitor, mode):
    rule = (f"{monitor['name']},{mode},{monitor['x']}x{monitor['y']},"
            f"{monitor['scale']},transform,{monitor.get('transform', 0)}")
    mirror = monitor.get('mirrorOf')
    if mirror and mirror != 'none':
        rule += f',mirror,{mirror}'
    return rule


def set_rule(rule):
    reply = command(['hyprctl', 'keyword', 'monitor', rule])
    if reply != 'ok':
        raise RuntimeError(reply)


def apply():
    power_saver = saving()
    if power_saver is None:
        return
    for monitor in monitors():
        if not re.match(r'^(eDP|LVDS|DSI)-', monitor['name']) or monitor.get('disabled'):
            continue
        mode, width, height, hz = select_mode(monitor, power_saver)
        if (monitor['width'] == width and monitor['height'] == height
                and abs(monitor['refreshRate'] - hz) < 0.5):
            continue
        original = monitor_rule(monitor,
                                f"{monitor['width']}x{monitor['height']}@{monitor['refreshRate']}")
        try:
            set_rule(monitor_rule(monitor, mode))
            time.sleep(0.5)
            current = next(m for m in monitors() if m['name'] == monitor['name'])
            if (current['width'] != width or current['height'] != height
                    or abs(current['refreshRate'] - hz) >= 0.5):
                raise RuntimeError(f"Display did not accept {width}x{height} at {hz:g} Hz")
        except Exception:
            set_rule(original)
            raise
        print(f"{monitor['name']}: {current['refreshRate']:.2f} Hz", flush=True)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--mode', metavar='OUTPUT', help='Print mode for the display switcher')
    args = parser.parse_args()
    if args.mode:
        monitor = next(m for m in monitors() if m['name'] == args.mode)
        print(select_mode(monitor, saving() is True)[0])
        return
    runtime = os.environ.get('XDG_RUNTIME_DIR')
    signature = os.environ.get('HYPRLAND_INSTANCE_SIGNATURE')
    if not runtime or not signature:
        raise RuntimeError('Run inside a Hyprland session')
    with (Path(runtime) / 'hypr' / signature / 'display-power.lock').open('w') as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        apply()


if __name__ == '__main__':
    try:
        main()
    except (OSError, ValueError, RuntimeError, StopIteration, subprocess.SubprocessError) as error:
        print(f'Display power setting: {error}', file=sys.stderr)
        sys.exit(1)
