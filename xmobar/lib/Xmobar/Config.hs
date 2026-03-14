{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE ImportQualifiedPost #-}
{-# LANGUAGE OverloadedStrings #-}

module Xmobar.Config (mkConfig) where

import Xmobar
import System.Process qualified as Process
import Text.Read qualified as Read
import Control.Exception qualified as Exception
import Data.Text qualified as Text
import Prelude

mkConfig :: IO Config
mkConfig = do
    eDPI :: Either IOError String <- Exception.try $ Process.readCreateProcess (Process.shell "xrdb -query | grep dpi") ""
    let mDPI :: Maybe Int = case eDPI of
                Left _ -> Nothing
                Right dpiNum -> Read.readMaybe
                          $ Text.unpack
                          $ Text.replace "\n" ""
                          $ Text.replace "Xft.dpi:\t" ""
                          $ Text.pack dpiNum
        (fontSize, offset, heightPx) = case mDPI of
                Just dpiNum -> if dpiNum >= 200 then ("20", 0, 26) else ("12", -1, 15)
                Nothing -> ("12", -1, 15)
    pure $
        defaultConfig
            { font = "DejaVu Sans Mono " <> fontSize
            , additionalFonts =
                [ "DejaVu Sans Mono italic 9"
                , "Font Awesome 6 Free Solid " <> fontSize
                ]
            , borderColor = "black"
            , border = FullB
            , bgColor = "black"
            , fgColor = "whitesmoke"
            , alpha = 128
            , position = TopSize C 100 heightPx
            , textOffset = offset
            , iconOffset = offset
            , lowerOnStart = True
            , pickBroadest = False
            , persistent = False
            , hideOnStart = False
            , iconRoot = "."
            , allDesktops = True
            , overrideRedirect = True
            , textOutputFormat = Ansi
            , commands =
                [ Run $ Com "echo" ["<fn=2>\xf242</fn>"] "baticon" 3600
                , Run $
                    BatteryP
                        ["BAT0", "ADP1"]
                        [ "-t"
                        , "<acstatus> (<left>%)"
                        , "-L"
                        , "10"
                        , "-H"
                        , "80"
                        , "-p"
                        , "3"
                        , "--"
                        , "-O"
                        , ""
                        , "-i"
                        , ""
                        , "-o"
                        , ""
                        , "-L"
                        , "-15"
                        , "-H"
                        , "-5"
                        , "-l"
                        , "red"
                        , "-m"
                        , "blue"
                        , "-h"
                        , "green"
                        , "-a"
                        , "notify-send -u critical 'Battery running out!!'"
                        , "-A"
                        , "3"
                        ]
                        600
                , Run $ DiskU [("/", "<fn=2>\xf0c7</fn> <free>")] [] 60
                , Run $
                    Cpu
                        [ "-L"
                        , "3"
                        , "-H"
                        , "50"
                        , "--high"
                        , "red"
                        ]
                        60
                , Run $ Memory ["-t", "Mem: <usedratio>%"] 60
                , Run $ Swap [] 10
                , Run $ Com "uname" ["-s", "-r"] "" 36000
                , Run $ Alsa "default" "Master" ["-t", "<fn=2>\xf027</fn> <volume>%", "--", "-O", "", "-o", ""]
                , Run $ Date "%a %b %_d %Y %H:%M" "date" 10
                , Run UnsafeStdinReader
                ]
            , sepChar = "%"
            , alignSep = "}{"
            , template =
                " %UnsafeStdinReader%}"
                    ++ "{<box type=Bottom width=2 mb=1 color=#98be65><fc=#98be65>%alsa:default:Master%</fc></box>"
                    ++ " <box type=Bottom width=2 mb=1 color=#ecbe7b><fc=#ecbe7b><action=`alacritty -e htop`>%cpu%</action></fc></box>"
                    ++ " <box type=Bottom width=2 mb=1 color=#ff6c6b><fc=#ff6c6b><action=`alacritty -e htop`>%memory%</action></fc></box>"
                    ++ " <box type=Bottom width=2 mb=1 color=#a9a1e1><fc=#a9a1e1>%disku%</fc></box>"
                    ++ " <box type=Bottom width=2 mb=1 color=#da8548><fc=#da8548>%baticon%%battery%</fc></box>"
                    ++ " <box type=Bottom width=2 mb=1 color=#46d9ff><fc=#46d9ff>%date%</fc></box> "
            }
