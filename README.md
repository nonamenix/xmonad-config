# Xmonad & Mate

## Install

```sh
sudo apt-get install ghc mate xmonad stack xcompmgr
```

## Replacing the default window manager

You will need to create a freedesktop.org desktop file for xmonad, probably in `/usr/share/applications/xmonad.desktop`

```ini
[Desktop Entry]
Type=Application
Name=XMonad
Exec=/usr/bin/xmonad
NoDisplay=true
X-GNOME-WMName=XMonad
X-GNOME-Autostart-Phase=WindowManager
X-GNOME-Provides=windowmanager
X-GNOME-Autostart-Notify=true
```

To replace `marco` with `xmonad` for all sessions, use the following (per user):

```sh
dconf write /org/mate/session/required-components/windowmanager xmonad
```

## Read more

- [Xmonad & Mate](./docs/mate.md)
