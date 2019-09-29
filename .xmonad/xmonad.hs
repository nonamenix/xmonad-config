import XMonad
import XMonad.Config.Gnome
import XMonad.Config.Desktop
import XMonad.Actions.WindowGo
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.EwmhDesktops
import XMonad.Layout.Grid
import XMonad.Layout.Tabbed
import XMonad.Layout.NoBorders
import XMonad.Layout.PerWorkspace
import XMonad.Layout.ResizableTile -- Actions.WindowNavigation is nice too
import XMonad.Layout.IM
import XMonad.Layout.Spacing
import XMonad.Layout.Reflect
import XMonad.Layout.StackTile
import XMonad.Layout.ThreeColumns
import XMonad.Layout.ComboP
import XMonad.Layout.Combo
import XMonad.Prompt 
import XMonad.Prompt.Shell
import XMonad.Util.EZConfig(additionalKeys)
import XMonad.Util.Run(spawnPipe, runInTerm)
import XMonad.Util.Themes
import System.IO
import qualified XMonad.StackSet as W
import Data.List
import Data.Monoid (All (All), mappend)
        
main = xmonad myConfig

myConfig = gnomeConfig
    { modMask = modm
    , logHook = spawn "wmname LG3D"
    , workspaces = ["1:ide", "2:web", "3:term", "4:personal", "5", "6:gimp", "7:additional", "8:skype", "9:im"]
    , terminal = "terminator"
    , borderWidth = 1
    , focusedBorderColor = myFocusedBorderColor
    , normalBorderColor = myNormalBorderColor
    , layoutHook = desktopLayoutModifiers myLayoutHook
    , manageHook = myManageHook <+> manageHook gnomeConfig
    , handleEventHook = fullscreenEventHook `mappend` handleEventHook gnomeConfig
    , XMonad.focusFollowsMouse = True
    , XMonad.clickJustFocuses = True
    } `additionalKeys` myKeys 
    where
        myFocusedBorderColor = "#990000"
        myNormalBorderColor = "#888888"
 
modm = mod4Mask
 
myTabConfig = def { inactiveBorderColor   = "#242424"
                  , inactiveColor         = "#242424"
                  , inactiveTextColor     = "#ffffff"
                  , activeBorderColor     = "#b22222"
                  , activeColor           = "#242424"
                  , activeTextColor       = "#ffffff"}
 
myLayoutHook = onWorkspace "9:im" pidginLayout 
    $ onWorkspace "8:skype" skypeLayout
    $ onWorkspace "7:additional" additionalDisplayLayout
    $ onWorkspace "1:ide" ideLayout
    $ onWorkspace "6:gimp" gimpLayout
    $ myTall ||| myGrid |||  myFull |||  Mirror myTall ||| myTabbed
    where
        additionalDisplayLayout = Mirror ( smartBorders (Tall nmaster delta 0.65) ) ||| Mirror ( ThreeColMid 1 (3/100) (1/2))
        pidginLayout = withIM (18/100) (Role "buddy_list") Grid 
        skypeLayout = withIM (18/100) skypeRoster Grid 
        gridLayout = spacing 8 Grid
        ideLayout = myFull ||| smartBorders (Tall nmaster  delta 0.75) ||| myTall 
        gimpLayout = myFull

        myFull = noBorders Full
        myTabbed = smartBorders (tabbed shrinkText myTabConfig)
        myTall = smartBorders (Tall nmaster delta ratio)
        myGrid = smartBorders Grid

        skypeRoster = ClassName "Skype" `And` Not (Role "ConversationsWindow")
        
        nmaster = 1 -- count of windows in master layout
        delta = 0.03 
        ratio = 0.5
 
myManageHook = composeAll
    [ className =? "Pidgin" --> doShift "9:im"
    , className =? "Skype" --> doShift "8:skype"
    , className =? "Gimp" --> doShift "6:gimp"
    , className =? "MPlayer" --> doFloat
    , className =? "jetbrains-pycharm" --> doShift "1:ide"
    , className =? "jetbrains-pycharm-community" --> doShift "1:ide"
    , resource  =? "gpicview" --> doFloat
    , title     =? "VLC media player" --> doFloat
    , title     =? "VLC (XVideo output)" --> doFullFloat
    , isFullscreen --> doFullFloat
    , manageDocks
    ]
 
myKeys = 
    [ -- System hotkeys
      ((modm .|. controlMask, xK_l), spawn "mate-screensaver-command -l")
    , ((modm .|. controlMask, xK_q), spawn "mate-session-quit")
 
    -- Application's hotkeys
    , ((modm .|. controlMask, xK_e), spawn "caja --browser /home/d_ivanof/")
    , ((modm .|. controlMask, xK_w), spawn "google-chrome-stable ")
    , ((modm .|. controlMask, xK_m), spawn "thunderbird")
    -- , ((modm .|. controlMask, xK_p), spawn "pidgin")
    , ((modm .|. controlMask, xK_i), spawn "pycharm")

 
    -- Another hotkeys 
    , ((modm, xK_p), shellPrompt def)
    ]
