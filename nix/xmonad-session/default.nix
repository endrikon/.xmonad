{
  pkgs,
  defaultUser ? "endrit",
  ...
}: {
  home-manager.users."${defaultUser}" = {
    xdg.configFile."xmonad" = {
      source = ../../xmonadrc;
      recursive = true;
    };
  };

  services = {
    xserver = {
      # Enable the X11 windowing system.
      enable = true;
      windowManager = {
        xmonad = {
          enable = true;
          enableContribAndExtras = true;
          extraPackages = hpkgs:
            with hpkgs; [
              xmonad
              xmonad-contrib
              xmonad-extras
            ];
        };
      };
      displayManager.lightdm.enable = true;
    };
    displayManager.defaultSession = "none+xmonad";

    picom.enable = true;
  };

  programs = {
    slock.enable = true;
  };

  environment = {
    systemPackages =
      (with pkgs.haskellPackages; [
        xmobar-app
      ])
      ++ (with pkgs; [
        ranger # TUI file browser
        alacritty
        dmenu # Expected by xmonad
        gxmessage # Used by xmonad to show help
        pavucontrol # PulseAudio volume control UI
        brightnessctl # Brightness control CLI
        pamixer # PulseAudio volume mixer
      ]);
  };
}
