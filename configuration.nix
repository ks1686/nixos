{ config, pkgs, ... }:

{
  # Imports
  imports = [
    ./hardware-configuration.nix
  ];

  # Core System Configuration
  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Kernel
  boot.kernelPackages = pkgs.linuxPackages_latest; # Use the latest stable kernel

  # Nix
  nix.settings = {
    auto-optimise-store = true; # Automatically optimize the Nix store
    max-jobs = 2;
  };

  # Nixpkgs
  nixpkgs.config.allowUnfree = true; # Allow installation of unfree packages
  nixpkgs.config.cudaSupport = true; # Enable CUDA support

  # Localization & Time
  time.timeZone = "America/New_York"; # Set your time zone
  i18n.defaultLocale = "en_US.UTF-8"; # Default locale settings
  i18n.extraLocaleSettings = {
    # Detailed locale settings
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

  # Hardware Configuration
  # Graphics
  hardware.graphics = {
    enable = true; # Enable general graphics support
    extraPackages = with pkgs; [ nvidia-vaapi-driver ]; # VA-API for NVIDIA
  };
  hardware.nvidia = {
    # NVIDIA specific settings
    package = config.boot.kernelPackages.nvidiaPackages.stable; # Use stable drivers
    open = true; # Use the open kernel module

    powerManagement = {
      # NVIDIA power management settings
      enable = true;
    };

    prime = {
      offload = {
        enable = true;
      };

      # Bus IDs
      amdgpuBusId = "PCI:101:0:0"; # AMD GPU bus ID
      nvidiaBusId = "PCI:1:0:0"; # NVIDIA GPU bus ID
    };
  };

  # Laptop-specific Hardware Services
  services.supergfxd.enable = true; # For graphics switching control on laptops
  services.asusd = {
    # For ASUS laptop specific controls
    enable = true;
    enableUserService = true;
  };

  # Bluetooth
  hardware.bluetooth.enable = true; # Enable Bluetooth
  hardware.bluetooth.powerOnBoot = true; # Power on Bluetooth at boot

  # Networking
  networking.hostName = "nixos"; # Define your hostname
  networking.networkmanager.enable = true; # Enable NetworkManager
  services.tailscale.enable = true; # Enable Tailscale VPN

  # Services
  # Display & Desktop Environment
  services.xserver = {
    enable = true;
    videoDrivers = [
      "amdgpu"
      "nvidia"
    ]; # Graphics drivers for Xorg
    xkb = {
      # Keyboard layout
      layout = "us";
      variant = "";
    };
    displayManager.gdm.enable = true; # Enable GDM as the display manager
    desktopManager.gnome.enable = true; # Enable GNOME desktop environment
  };
  environment.gnome.excludePackages = with pkgs; [
    geary
    gnome-calculator
    gnome-calendar
    gnome-clocks
    gnome-connections
    gnome-contacts
    epiphany
    gnome-maps
    gnome-online-accounts
    gnome-software
    gnome-text-editor
    gnome-tour
    gnome-user-docs
    gnome-user-share
    gnome-weather
    simple-scan
    snapshot
    yelp
  ];

  # Sound
  services.pulseaudio.enable = false; # Disable PulseAudio (using PipeWire)
  security.rtkit.enable = true; # Real-time kit for better audio performance
  services.pipewire = {
    # PipeWire sound server
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true; # Enables PipeWire's PulseAudio replacement
  };

  # GPG Agent
  services.pcscd.enable = true; # Smart card daemon, often used with GPG
  programs.gnupg.agent = {
    # GnuPG agent settings
    enable = true;
    pinentryPackage = pkgs.pinentry-gnome3; # Use Qt-based pinentry
    enableSSHSupport = true; # Enable SSH agent support
  };

  # Printing
  services.printing.enable = true; # Enable CUPS for printing
  services.printing.drivers = [ pkgs.hplip ]; # HP printer drivers
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # Ollama AI Service
  services.ollama = {
    # Ollama LLM service
    enable = true;
    acceleration = "cuda"; # Use CUDA for acceleration
  };

  # User Configuration
  users.users.ks1686 = {
    isNormalUser = true;
    description = "Karim Smires";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
      "kvm"
      "adbusers"
    ]; # Sudo, network, docker access
    shell = pkgs.fish; # Set default shell to Fish
    linger = true; # Allows user services to run without active login sessions
    packages = with pkgs; [
      # User-specific packages can be added here if not system-wide
    ];
  };

  # Shell Configuration (System-wide)
  programs.fish.enable = true; # Make Fish shell available and configure it globally

  # Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.adwaita-mono # Adwaita Mono Nerd Font
  ];

  # Programs & Applications (System-wide configurations)
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports for Steam Local Network Game Transfers
  };
  programs.adb.enable = true; # Enable ADB for Android devices

  # AppImage Support
  programs.appimage.enable = true; # Enable AppImage support
  programs.appimage.binfmt = true; # Register AppImages with binfmt_misc

  # Flatpak Support
  services.flatpak.enable = true; # Enable Flatpak support
  systemd.services.flatpak-repo = {
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.flatpak ];
    script = ''
      flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    '';
  };

  # Virtualization & Containers
  virtualisation.docker.enable = true; # Enable Docker daemon
  hardware.nvidia-container-toolkit.enable = true; # Enable NVIDIA support for Docker containers

  # Environment & System Packages
  environment.systemPackages = with pkgs; [
    # System Utilities
    aria2 # Download utility
    fwupd # Firmware update daemon and utility
    gh # GitHub CLI
    git # Version control system
    gnumake
    gnupg # For GPG key management
    hunspell # Spell checker
    hunspellDicts.en-us-large # English dictionary for Hunspell
    rm-improved # Safer rm alternative
    qemu # Generic machine emulator and virtualizer
    quickemu # Utility to quickly create and run virtual machines
    yt-dlp

    # Shell Enhancements & Tools
    fishPlugins.bass
    fishPlugins.done
    fishPlugins.forgit
    fishPlugins.plugin-sudope
    lazygit # TUI for git
    lazydocker # TUI for docker

    # GNOME
    dconf-editor # GNOME dconf editor
    gnomecast # Cast to Chromecast devices
    gnome-boxes # Virtual machine manager for GNOME
    gnome-tweaks # Tweaks for GNOME
    gnomeExtensions.arcmenu # Arc Menu extension
    gnomeExtensions.caffeine # Caffeine extension to prevent sleep
    gnomeExtensions.clipboard-indicator # Clipboard manager
    gnomeExtensions.dash-to-dock # Dash to Dock extension
    gnomeExtensions.docker # Docker extension for GNOME
    gnomeExtensions.disable-3-finger-gestures # Disable 3-finger gestures
    gnomeExtensions.gpu-supergfxctl-switch # Control graphics switching
    gnomeExtensions.impatience # Remove GNOME shell delay
    gnomeExtensions.just-perfection # GNOME shell tweaks
    gnomeExtensions.night-theme-switcher # Night theme switcher
    gnomeExtensions.tiling-assistant # Tiling assistant for GNOME

    # Desktop Tools & Utilities
    audacity # Audio editing software
    blender # 3D creation suite
    bottles # Windows application manager
    davinci-resolve # Video editing software
    fsearch # File search utility
    gearlever # Manage AppImages
    gparted # Partition editor
    protonplus # Proton Manager
    prusa-slicer # 3D printing slicer
    thunderbird # Email client

    # Browsers
    google-chrome # Google Browser
    tor-browser # Tor Browser for anonymous browsing

    # Communications
    discord

    # Development Tools
    android-studio # Android development IDE
    jetbrains.idea-ultimate
    jetbrains.pycharm-professional
    jetbrains.rider # JetBrains Rider for .NET development
    unityhub # Hub for Unity game engine
    vscode.fhs # Microsoft VSCode

    # AI Tools
    alpaca # LLM GUI
    cudatoolkit # CUDA support for AI tools
    ollama # CLI for Ollama
    opencv # OpenCV for computer vision

    # Gaming
    heroic # Epic Games and GOG launcher
    itch # Itch.io game launcher
    prismlauncher # Minecraft launcher

    # Wine & Windows Compatibility
    dxvk # DirectX to Vulkan translation layer
    wineWowPackages.stable # Wine for 32-bit and 64-bit applications

    # Language Specific Development
    # C/C++
    clang-tools
    cmake
    gcc
    # DotNet
    dotnet-sdk
    mono
    # JVM
    gradle
    openjdk
    # LaTeX
    texlive.combined.scheme-full
    #Nix
    nil
    nixfmt-rfc-style
    # Node.js
    nodejs
    pnpm
    nodePackages.prettier
    # Python

    python3
    ruff # Python linter/formatter
    uv # Python package installer/resolver
    # TypeScript
    typescript
  ];

  # Environment Variables
  environment.sessionVariables = {
    # Example: Add custom paths for user scripts
    PATH = [
      "/home/ks1686/.local/share/JetBrains/Toolbox/scripts"
      "\${PATH}"
    ];
  };

  # System State
  # This should match the NixOS version you initially installed or upgraded to.
  # Do not change this simply to upgrade NixOS. Instead, use 'nixos-rebuild switch --upgrade'.
  system.stateVersion = "25.05";
}
