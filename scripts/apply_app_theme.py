#!/usr/bin/env python3
"""Install/apply the app palette. --session reapplies desktop settings at login."""
import argparse
from datetime import datetime
import json
import os
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
HOME_DIR = Path.home()
STATE = HOME_DIR / '.local/state/shine-theme'
SETTINGS = {
    'gtk-theme': 'Shine-Everforest',
    'color-scheme': 'prefer-dark',
    'icon-theme': 'Papirus-Dark',
    'accent-color': 'green',
}


def link(relative, backup):
    source = ROOT / relative
    target = HOME_DIR / relative
    if target.is_symlink() and target.resolve() == source.resolve():
        return
    if target.exists() or target.is_symlink():
        saved = backup / relative
        saved.parent.mkdir(parents=True, exist_ok=True)
        target.rename(saved)
    target.parent.mkdir(parents=True, exist_ok=True)
    target.symlink_to(source, target_is_directory=source.is_dir())


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--session', action='store_true', help='Apply settings only; do not install files')
    args = parser.parse_args()
    if not args.session:
        subprocess.run(['/usr/bin/python3', str(ROOT / 'scripts/build_app_themes.py')], check=True)
        backup = STATE / 'backups' / datetime.now().strftime('%Y%m%d-%H%M%S')
        for relative in ('.themes', '.config/themes', '.config/gtk-3.0', '.config/gtk-4.0',
                         '.config/qt5ct', '.config/qt6ct',
                         '.config/environment.d/90-shine-theme.conf',
                         '.config/xdg-desktop-portal/hyprland-portals.conf',
                         '.config/microsoft-edge-stable-flags.conf'):
            link(relative, backup)
    schema = 'org.gnome.desktop.interface'
    keys = subprocess.check_output(['/usr/bin/gsettings', 'list-keys', schema], text=True).split()
    if not args.session:
        STATE.mkdir(parents=True, exist_ok=True)
        snapshot = STATE / 'original-desktop-settings.json'
        if not snapshot.exists():
            old = {key: subprocess.check_output(['/usr/bin/gsettings', 'get', schema, key], text=True).strip()
                   for key in SETTINGS if key in keys}
            snapshot.write_text(json.dumps(old, indent=2) + '\n')
    for key, value in SETTINGS.items():
        if key in keys:
            subprocess.run(['/usr/bin/gsettings', 'set', schema, key, value], check=True)
    os.environ['QT_QPA_PLATFORMTHEME'] = 'qt5ct'
    # Both installed qt5ct and qt6ct plugins accept this key. Update future
    # compositor-launched apps and D-Bus/systemd-activated applications now.
    if os.environ.get('HYPRLAND_INSTANCE_SIGNATURE'):
        subprocess.run(['hyprctl', 'keyword', 'env', 'QT_QPA_PLATFORMTHEME,qt5ct'], check=True)
    subprocess.run(['dbus-update-activation-environment', '--systemd', 'QT_QPA_PLATFORMTHEME'], check=True)
    print('Shine Everforest applied. Reopen apps to load their CSS/palette; Edge loads its theme on next launch.')


if __name__ == '__main__':
    try:
        main()
    except (OSError, subprocess.SubprocessError) as error:
        sys.exit(f'Could not apply app theme: {error}')
