{ config, pkgs, ... }:

{
  # =========================================================================
  # IMPORTS
  # =========================================================================
  imports = [
  ];

  # =========================================================================
  # CORE HOME MANAGER SETTINGS
  # =========================================================================
  home.stateVersion = "25.05"; # State version
  home.username = "ks1686";
  home.homeDirectory = "/home/ks1686";
  programs.home-manager.enable = true; # Enable Home Manager

  # =========================================================================
  # USER-SPECIFIC SHELL CONFIGURATION
  # =========================================================================
  programs.fish = {
    enable = true; # Enable Fish shell
    shellAbbrs = {
      # Shell abbreviations
      c = "clear";
      nixconf = "env VISUAL='code --wait' sudoedit /etc/nixos/configuration.nix";
      nixbuild = "sudo nixos-rebuild switch --upgrade";
      nixclean = "sudo nix-collect-garbage -d; sudo /run/current-system/bin/switch-to-configuration boot";
      nixhome = "env VISUAL='code --wait' sudoedit /etc/nixos/home-ks1686.nix";
    };
    shellInit = ''
      # Dracula Color Palette
      set -l foreground f8f8f2
      set -l selection 44475a
      set -l comment 6272a4
      set -l red ff5555
      set -l orange ffb86c
      set -l yellow f1fa8c
      set -l green 50fa7b
      set -l purple bd93f9
      set -l cyan 8be9fd
      set -l pink ff79c6

      # Syntax Highlighting Colors
      set -gx fish_color_normal $foreground
      set -gx fish_color_command $cyan
      set -gx fish_color_keyword $pink
      set -gx fish_color_quote $yellow
      set -gx fish_color_redirection $foreground
      set -gx fish_color_end $orange
      set -gx fish_color_error $red
      set -gx fish_color_param $purple
      set -gx fish_color_comment $comment
      set -gx fish_color_selection --background=$selection
      set -gx fish_color_search_match --background=$selection
      set -gx fish_color_operator $green
      set -gx fish_color_escape $pink
      set -gx fish_color_autosuggestion $comment
      set -gx fish_color_cancel $red --reverse
      set -gx fish_color_option $orange

      # Default Prompt Colors
      set -gx fish_color_cwd $green
      set -gx fish_color_host $purple
      set -gx fish_color_host_remote $purple
      set -gx fish_color_user $cyan

      # Completion Pager Colors
      set -gx fish_pager_color_progress $comment
      set -gx fish_pager_color_background
      set -gx fish_pager_color_prefix $cyan
      set -gx fish_pager_color_completion $foreground
      set -gx fish_pager_color_description $comment
      set -gx fish_pager_color_selected_background --background=$selection
      set -gx fish_pager_color_selected_prefix $cyan
      set -gx fish_pager_color_selected_completion $foreground
      set -gx fish_pager_color_selected_description $comment
      set -gx fish_pager_color_secondary_background
      set -gx fish_pager_color_secondary_prefix $cyan
      set -gx fish_pager_color_secondary_completion $foreground
      set -gx fish_pager_color_secondary_description $comment
    '';
  };

  programs.alacritty = {
    enable = true; # Enable Alacritty terminal
    settings = {
      general.import = [ "~/.config/alacritty/dracula.toml" ]; # Import Alacritty configuration
      window.dimensions = {
        columns = 70; # Terminal width
        lines = 20; # Terminal height
      };
      font = {
        normal = {
          family = "AdwaitaMono Nerd Font";
          style = "Regular";
        };
        bold = {
          family = "AdwaitaMono Nerd Font";
          style = "Bold";
        };
        italic = {
          family = "AdwaitaMono Nerd Font";
          style = "Italic";
        };
        bold_italic = {
          family = "AdwaitaMono Nerd Font";
          style = "Bold Italic";
        };
      };
    };
  };

  # =========================================================================
  # DEVELOPMENT & VERSION CONTROL
  # =========================================================================
  programs.git = {
    enable = true; # Enable Git
    lfs.enable = true; # Git LFS
    userName = "Karim Smires";
    userEmail = "k.smires1686@gmail.com";
    extraConfig = {
      color.ui = "auto";
      branch.current = "cyan bold reverse";
      branch.local = "white";
      branch.plain = "";
      branch.remote = "cyan";
      diff.commit = "";
      diff.func = "cyan";
      diff.plain = "";
      diff.whitespace = "magenta reverse";
      diff.meta = "white";
      diff.frag = "cyan bold reverse";
      diff.old = "red";
      diff.new = "green";
      grep.context = "";
      grep.filename = "";
      grep.function = "";
      grep.linenumber = "white";
      grep.match = "";
      grep.selected = "";
      grep.separator = "";
      interactive.error = "";
      interactive.header = "";
      interactive.help = "";
      interactive.prompt = "";
      status.added = "green";
      status.changed = "yellow";
      status.header = "";
      status.localBranch = "";
      status.nobranch = "";
      status.remoteBranch = "cyan bold";
      status.unmerged = "magenta bold reverse";
      status.untracked = "red";
      status.updated = "green bold";
    };
  };

  programs.lazygit = {
    enable = true; # Enable Lazygit
    settings = {
      theme.activeBorderColor = [
        "#FF79C6"
        "bold"
      ];
      theme.inactiveBorderColor = [ "#BD93F9" ];
      theme.searchingActiveBorderColor = [
        "#8BE9FD"
        "bold"
      ];
      theme.optionsTextColor = [ "#6272A4" ];
      theme.selectedLineBgColor = [ "#6272A4" ];
      theme.inactiveViewSelectedLineBgColor = [ "bold" ];
      theme.cherryPickedCommitFgColor = [ "#6272A4" ];
      theme.cherryPickedCommitBgColor = [ "#8BE9FD" ];
      theme.markedBaseCommitFgColor = [ "#8BE9FD" ];
      theme.markedBaseCommitBgColor = [ "#F1FA8C" ];
      theme.unstagedChangesColor = [ "#FF5555" ];
      theme.defaultFgColor = [ "#F8F8F2" ];
    };
  };

  # =========================================================================
  # SECURITY & KEY MANAGEMENT
  # =========================================================================
  programs.gpg = {
    enable = true; # Enable GPG
  };

  services.gpg-agent = {
    enable = true; # Enable GPG agent
    enableFishIntegration = true; # Fish integration
    pinentry.package = pkgs.pinentry-gnome3; # Pinentry package
    enableSshSupport = true; # GPG agent SSH support
  };

  # SSH Agent (Note: 'services.ssh-agent' is not a typical Home Manager option)
  services.ssh-agent.enable = true;

  # =========================================================================
  # THEMING
  # =========================================================================

  # =========================================================================
  # HOME PACKAGES
  # =========================================================================
  home.packages = with pkgs; [
  ];
}
