Articles:

https://wiki.haskell.org/Xmonad/Using_xmonad_in_MATE

## Requirements

```
sudo apt-get install ghc mate xmonad stack xcompmgr
```

## Replacing the default window manager

You will need to create a freedesktop.org desktop file for xmonad, probably in `/usr/share/applications/xmonad.desktop`

```
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

```
dconf write /org/mate/session/required-components/windowmanager xmonad
```
