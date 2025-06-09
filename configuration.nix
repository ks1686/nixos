{ config, pkgs, ... }:

{
  # =========================================================================
  # IMPORTS
  # =========================================================================
  imports = [
    ./hardware-configuration.nix # Hardware-specific settings
  ];

  # =========================================================================
  # OPERATING SYSTEM & CORE CONFIGURATION
  # =========================================================================
  # Fundamental settings for NixOS behavior, boot, hardware, and base system.

  # Bootloader & Encryption
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };
  boot.initrd.luks.devices."luks-09124d87-d012-4b1d-8f86-037db7f25b8b".device =
    "/dev/disk/by-uuid/09124d87-d012-4b1d-8f86-037db7f25b8b"; # LUKS partition

  # Nix Ecosystem
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-substituters = [ "https://cache.nixos.org/" ];
    auto-optimise-store = true;
  };
  nixpkgs.config = {
    allowUnfree = true; # Allow non-free packages
  };

  # System Basics
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };
  networking.hostName = "nixos";
  system.stateVersion = "25.05"; # Manages stateful settings compatibility

  # Hardware Enablement
  hardware.graphics.enable = true;
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false; # Adjust for laptop power tuning if needed
    powerManagement.finegrained = false;
    open = true; # Use open-source NVIDIA kernel module
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    prime = {
      amdgpuBusId = "PCI:101:0:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  # Fonts
  fonts = {
    fontDir.enable = true;
    packages = with pkgs; [
      nerd-fonts.hack
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
    ];
    fontconfig = {
      defaultFonts = {
        monospace = [ "Hack Nerd Font Mono" ];
      };
    };
  };

  # =========================================================================
  # SYSTEM SERVICES
  # =========================================================================
  # Background daemons and services providing system functionalities.

  # Desktop Environment
  services.xserver = {
    enable = true;
    videoDrivers = [
      "nvidia"
      "amdgpu"
    ];
    xkb = {
      layout = "us";
      variant = "";
    };
  };
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Audio
  services.pulseaudio.enable = false; # Disabled in favor of PipeWire
  security.rtkit.enable = true; # For low-latency audio
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true; # PipeWire's PulseAudio compatibility
  };

  # Networking Services
  networking.networkmanager.enable = true;
  services.tailscale.enable = true;
  services.tor = {
    enable = true;
    client.enable = true;
  };
  services.avahi = {
    enable = true;
    nssmdns4 = true; # mDNS for IPv4 hostname resolution
    openFirewall = true;
  };

  # Laptop & Peripheral Control Services
  services.supergfxd.enable = true; # For graphics switching (e.g., ASUS laptops)
  services.asusd = {
    # ASUS laptop specific controls
    enable = true;
    enableUserService = true;
  };
  services.printing = {
    enable = true;
    drivers = [ pkgs.hplip ]; # HP printer drivers
  };

  # Flatpak
  services.flatpak = {
    enable = true;
  };
  systemd.services.flatpak-repo = {
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.flatpak ];
    script = ''
      flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    '';
  };

  # =========================================================================
  # SOFTWARE, APPLICATIONS & USER ENVIRONMENT
  # =========================================================================
  # User accounts, program configurations, and installed packages.

  # User Account & Shell Configuration: ks1686
  users.users.ks1686 = {
    isNormalUser = true;
    description = "Karim Smires";
    extraGroups = [
      "docker"
      "networkmanager"
      "wheel"
    ];
    shell = pkgs.fish;
    packages = with pkgs.kdePackages; [
      # KDE-specific packages for ks1686
      calligra
      elisa
      gwenview
      isoimagewriter
      keysmith
      kjournald
      kleopatra
      kwave
      okular
      partitionmanager
      plasma-thunderbolt
      sddm-kcm
      skanpage
    ];
  };

  programs.fish = {
    enable = true; # System-wide fish enablement
    useBabelfish = true; # For bash compatibility
    shellInit = ''
      # User-specific settings for ks1686
      if test "$USER" = "ks1686"
        fish_config prompt choose astronaut
        set -U fish_greeting ""

        # Aliases
        alias c "clear"
        alias nixconf "env VISUAL='code --wait' sudoedit /etc/nixos/configuration.nix"
        alias nixbuild "sudo nixos-rebuild switch --upgrade"
        alias nixclean "sudo nix-collect-garbage -d; sudo /run/current-system/bin/switch-to-configuration boot"
        alias mount_umbrel 'sudo mount -t cifs "//umbrel.emerald-themis.ts.net/karim smires\'s umbrel" ~/Umbrel -o credentials=/home/ks1686/.smbcredentials_umbrel,uid=$(id -u),gid=$(id -g),iocharset=utf8,nofail'
        alias umount_umbrel "sudo umount ~/Umbrel"
      end
    '';
  };

  programs.git = {
    enable = true;
    lfs.enable = true;
    config = {
      # Global git config, effectively user-specific for a single-user machine
      user = {
        name = "Karim Smires";
        email = "k.smires1686@gmail.com";
      };
      diff.tool = "kdiff3";
      merge.tool = "kdiff3";
    };
  };

  # Application-Specific System Settings
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
  };
  programs.adb.enable = true;
  programs.appimage = {
    enable = true;
    binfmt = true; # Allows direct execution of AppImages
  };

  # Virtualization & Containers
  virtualisation.docker.enable = true;
  hardware.nvidia-container-toolkit.enable = true; # NVIDIA GPU support for Docker

  # System-Wide Packages
  environment.systemPackages = with pkgs; [
    # --- AI and ML ---
    cudatoolkit
    # --- Browsers ---
    google-chrome
    # --- Creation ---
    blender
    davinci-resolve
    freecad-wayland
    gimp
    lmms
    obs-studio
    prusa-slicer
    # --- Communication ---
    betterdiscordctl
    discord
    # --- Gaming ---
    alvr
    gamemode
    gamescope
    heroic
    itch
    prismlauncher
    r2modman
    ryubing # Consider checking 'ryubing' package name
    # --- Hardware ---
    arduino
    arduino-cli
    qFlipper
    # --- IDE ---
    android-studio
    arduino-ide
    jetbrains.clion
    jetbrains.idea-ultimate
    jetbrains.rider
    jetbrains.rust-rover
    jetbrains.webstorm
    vscode.fhs
    # --- Programming Languages ---
    cargo
    dotnet-sdk
    gcc
    gradle
    mono
    nil
    nixfmt-rfc-style
    nodePackages.prettier
    nodejs
    openjdk
    pnpm
    python3
    ruff
    rustc
    typescript
    uv
    # --- System ---
    aria2
    bottles
    cifs-utils
    dxvk
    fsearch
    fwupd
    gearlever
    hunspell
    hunspellDicts.en-us-large
    kdiff3
    ktailctl
    lazydocker
    protonplus
    qemu
    quickemu
    quickgui
    rm-improved
    sirikali
    supergfxctl-plasmoid
    tealdeer
    warehouse
    wineWowPackages.stable
    yt-dlp
  ];
}
