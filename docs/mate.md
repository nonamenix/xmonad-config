## Using xmonad in MATE

Original: [wiki.haskell.org](https://wiki.haskell.org/Xmonad/Using_xmonad_in_MATE)

MATE is a supported fork of Gnome 2, with various components renamed to avoid collisions with Gnome components. At present, Fedora ships both MATE and an xmonad session using it (`xmonad-mate` package); for other platforms, look for MATE in your package manager or check http://mate-desktop.org.

The current development version of `xmonad-contrib` from git has an `XMonad.Config.Mate` which should work out of the box on most platforms. For earlier versions, you may want to copy `XMonad.Config.Gnome` to `~/.xmonad/lib/XMonad/Config/Mate.hs` and replace (matching case as appropriate) all instances of `gnome` with `mate`. This will affect the terminal, the session manager connection, and the X11 message sent to activate the run command dialog, among other things.

## Replacing the default window manager

You will need to create a `freedesktop.org` desktop file for `xmonad`, probably in `/usr/share/applications/xmonad.desktop`:

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

Alternatively, you may need to set this via gsettings on distributions such as Arch

```sh
gsettings set org.mate.session.required-components.windowmanager xmonad
```

(TODO: alternative session file)

## Recent MATE with `window-manager-launcher`

Recently Linux Mint upgraded its MATE to use a separate script to start the window manager; as shipped, it only works with a limited number of window managers that does not include xmonad. I have minimally modified it to support other window managers, including a first cut at user-installed ones. (If someone has a better way to handle this, please do so; I have no way to host this file currently.) My changes are both marked with `# sigh`.

```python
#!/usr/bin/python3

import sys
import os
import gettext
import signal
import subprocess
import time
import gi
from gi.repository import Gio

# i18n
gettext.install("mintdesktop", "/usr/share/linuxmint/locale")

settings = Gio.Settings("com.linuxmint.desktop")

# Detect which DE is running
if "XDG_CURRENT_DESKTOP" not in os.environ:
    print ("window-manager-launcher: XDG_CURRENT_DESKTOP is not set! Exiting..")
    sys.exit(0)

current_desktop = os.environ["XDG_CURRENT_DESKTOP"]

if current_desktop not in ["MATE", "XFCE"]:
    print ("Current desktop %s is not supported." % current_desktop)
    sys.exit(0)

if current_desktop == "MATE":
    wm = settings.get_string("mate-window-manager")
else:
    wm = settings.get_string("xfce-window-manager")

# Kill all compositors/managers first
p = subprocess.Popen(['ps', '-u', str(os.getuid())], stdout=subprocess.PIPE)
out, err = p.communicate()
processes_found = False
for process in ['compton', "marco", "xfwm4", "compiz", "metacity", "openbox", "awesome" ]:
    for line in out.splitlines():
        pname = line.decode('utf-8').split()[-1]
        if process in pname:
            pid = int(line.split(None, 1)[0])
            print ("Killing pid %d (%s)" % (pid, pname))
            try:
                os.kill(pid, signal.SIGKILL)
            except Exception as e:
                print ("Failed to kill process %d (%s): %s" % (pid, pname, e))
            processes_found = True

if (processes_found):
    # avoid race conditions before launching new WMs
    print ("Waiting 0.2 seconds...")
    time.sleep(0.2)

# sigh
os.environ["PATH"] += ':' + os.path.expanduser("~/.local/bin")

if wm == "marco":
    settings = Gio.Settings("org.mate.Marco.general")
    settings.set_boolean("compositing-manager", False)
    subprocess.Popen(["marco", "--no-composite", "--replace"])
elif wm == "marco-composite":
    settings = Gio.Settings("org.mate.Marco.general")
    settings.set_boolean("compositing-manager", True)
    subprocess.Popen(["marco", "--composite", "--replace"])
elif wm == "marco-compton":
    settings = Gio.Settings("org.mate.Marco.general")
    settings.set_boolean("compositing-manager", False)
    subprocess.Popen(["marco", "--no-composite", "--replace"])
    time.sleep(2)
    subprocess.Popen(["compton", "--backend", "glx", "--vsync", "opengl-swc"])
elif wm == "xfwm4":
    subprocess.Popen(["xfconf-query", "-c", "xfwm4", "-p", "/general/use_compositing", "--set", "false"])
    subprocess.Popen(["xfwm4", "--compositor=off", "--replace"])
elif wm == "xfwm4-composite":
    subprocess.Popen(["xfconf-query", "-c", "xfwm4", "-p", "/general/use_compositing", "--set", "true"])
    subprocess.Popen(["xfwm4", "--compositor=on", "--replace"])
elif wm == "xfwm4-compton":
    subprocess.Popen(["xfconf-query", "-c", "xfwm4", "-p", "/general/use_compositing", "--set", "false"])
    subprocess.Popen(["xfwm4", "--compositor=off", "--replace"])
    time.sleep(2)
    subprocess.Popen(["compton", "--backend", "glx", "--vsync", "opengl-swc"])
elif wm == "compiz":
    subprocess.Popen(["compiz", "--replace"])
elif wm == "metacity":
    settings = Gio.Settings("org.gnome.metacity")
    settings.set_boolean("compositing-manager", False)
    subprocess.Popen(["metacity", "--replace"])
elif wm == "metacity-composite":
    settings = Gio.Settings("org.gnome.metacity")
    settings.set_boolean("compositing-manager", True)
    subprocess.Popen(["metacity", "--replace"])
elif wm == "metacity-compton":
    settings = Gio.Settings("org.gnome.metacity")
    settings.set_boolean("compositing-manager", False)
    subprocess.Popen(["metacity", "--replace"])
    time.sleep(2)
    subprocess.Popen(["compton", "--backend", "glx", "--vsync", "opengl-swc"])
elif wm == "openbox":
    subprocess.Popen(["openbox", "--replace"])
elif wm == "openbox-compton":
    subprocess.Popen(["openbox", "--replace"])
    time.sleep(2)
    subprocess.Popen(["compton", "--backend", "glx", "--vsync", "opengl-swc"])
elif wm == "awesome":
    # subprocess.call(["killall", "marco", "xfwm4", "compiz", "metacity", "openbox", "awesome"]) # Kill all other window managers that might possibly still be running
    # time.sleep(0.1) # Wait some time until really all other window managers are killed otherwise awesome won't start up
    subprocess.Popen(["awesome"])
    if current_desktop == "MATE":  # The mate panel seems to move up a bit when starting awesome
        subprocess.Popen(["mate-panel", "--replace"])  # this seems to fix this issue
# sigh
else:
    subprocess.Popen([wm, "--replace"])
```
