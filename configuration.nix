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

  # Nixpkgs
  nixpkgs.config.allowUnfree = true; # Allow installation of unfree packages
  nixpkgs.config.packageOverrides = pkgs: { # Customize packages
    environment.plasma6.excludePackages = with pkgs.kdePackages; [
      elisa
      kate
      khelpcenter
      plasma-browser-integration
    ];
  };

  # Localization & Time
  time.timeZone = "America/New_York"; # Set your time zone
  i18n.defaultLocale = "en_US.UTF-8";  # Default locale settings
  i18n.extraLocaleSettings = {        # Detailed locale settings
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
  hardware.nvidia = { # NVIDIA specific settings
    package = config.boot.kernelPackages.nvidiaPackages.beta; # Use beta drivers
    open = false;    # Use the proprietary kernel module
  };

  # Laptop-specific Hardware Services
  services.supergfxd.enable = true; # For graphics switching control on laptops
  services.asusd = {                # For ASUS laptop specific controls
    enable = true;
    enableUserService = true;
  };

  # Bluetooth
  hardware.bluetooth.enable = true;       # Enable Bluetooth
  hardware.bluetooth.powerOnBoot = true; # Power on Bluetooth at boot

  # Networking
  networking.hostName = "nixos"; # Define your hostname
  networking.networkmanager.enable = true; # Enable NetworkManager
  services.tailscale.enable = true;        # Enable Tailscale VPN

  # Services
  # Display & Desktop Environment
  services.xserver = {
    enable = true;
    videoDrivers = [ "nvidia" "amdgpu" ]; # Graphics drivers for Xorg
    xkb = {                               # Keyboard layout
      layout = "us";
      variant = "";
    };
  };
  services.displayManager.sddm.enable = true;    # Enable SDDM display manager
  services.desktopManager.plasma6.enable = true; # Enable KDE Plasma 6 Desktop

  # Sound
  services.pulseaudio.enable = false; # Disable PulseAudio (using PipeWire)
  security.rtkit.enable = true;       # Real-time kit for better audio performance
  services.pipewire = {               # PipeWire sound server
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true; # Enables PipeWire's PulseAudio replacement
  };

  # GPG Agent
  services.pcscd.enable = true; # Smart card daemon, often used with GPG
  programs.gnupg.agent = {      # GnuPG agent settings
    enable = true;
    pinentryPackage = pkgs.pinentry-qt; # Use Qt-based pinentry
    enableSSHSupport = true;            # Enable SSH agent support
  };

  # Printing
  services.printing.enable = true; # Enable CUPS for printing

  # Ollama AI Service
  services.ollama = { # Ollama LLM service
    enable = true;
    acceleration = "cuda"; # Use CUDA for acceleration
  };

  # User Configuration
  users.users.ks1686 = {
    isNormalUser = true;
    description = "Karim Smires";
    extraGroups = [ "networkmanager" "wheel" "docker" ]; # Sudo, network, docker access
    shell = pkgs.fish; # Set default shell to Fish
    linger = true;     # Allows user services to run without active login sessions
    packages = with pkgs; [
      # User-specific packages can be added here if not system-wide
    ];
  };

  # Shell Configuration (System-wide)
  programs.fish.enable = true; # Make Fish shell available and configure it globally

  # Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.hack # Example: Hack Nerd Font
  ];

  # Programs & Applications (System-wide configurations)
  programs.firefox.enable = true; # Basic Firefox integration
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;        # Open ports for Steam Remote Play
    dedicatedServer.openFirewall = true;   # Open ports for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports for Steam Local Network Game Transfers
  };

  # AppImage Support
  programs.appimage.enable = true;  # Enable AppImage support
  programs.appimage.binfmt = true; # Register AppImages with binfmt_misc

  # Virtualization & Containers
  virtualisation.docker.enable = true; # Enable Docker daemon
  hardware.nvidia-container-toolkit.enable = true; # Enable NVIDIA support for Docker containers

  # Environment & System Packages
  environment.systemPackages = with pkgs; [
    # System Utilities
    fwupd          # Firmware update daemon and utility
    gh             # GitHub CLI
    git            # Version control system
    gnupg          # For GPG key management
    hunspell       # Spell checker
    hunspellDicts.en-us-large # English dictionary for Hunspell
    rm-improved    # Safer rm alternative
    qemu           # Generic machine emulator and virtualizer
    quickemu       # Utility to quickly create and run virtual machines

    # Shell Enhancements & Tools
    fishPlugins.bass
    fishPlugins.done
    fishPlugins.forgit
    fishPlugins.plugin-sudope
    lazygit        # TUI for git
    lazydocker     # TUI for docker

    # Desktop Tools & Utilities
    blender        # 3D creation suite
    gearlever      # Manage AppImages
    kdePackages.koi # Image viewer from KDE Gear
    kdePackages.kfind # File search utility from KDE Gear
    mesa-demos     # OpenGL/Mesa demos (e.g., glxinfo, glxgears)
    supergfxctl-plasmoid # Plasma widget for supergfxctl

    # Browsers
    google-chrome

    # Communications
    discord

    # Development Tools
    unityhub        # Hub for Unity game engine
    vscode.fhs      # Microsoft VSCode

    # AI Tools (CLI/Libraries)
    ollama # CLI for Ollama

    # Gaming
    heroic         # Epic Games and GOG launcher
    itch           # Itch.io game launcher
    prismlauncher  # Minecraft launcher

    # Wine & Windows Compatibility
    wineWowPackages.stable # Wine for 32-bit and 64-bit applications
    winetricks       # Helper script for Wine

    # Mobile Development
    android-tools  # Android SDK platform tools (adb, fastboot)

    # Language Specific Development
    # C/C++
    cmake
    gcc
    # DotNet
    dotnet-sdk
    mono
    # JVM
    gradle
    openjdk
    # Node.js
    nodejs
    pnpm
    # Python
    python3
    uv    # Python package installer/resolver
    # TypeScript
    typescript
  ];

  # Environment Variables
  environment.sessionVariables = {
    # Example: Add custom paths for user scripts
    PATH = [ "/home/ks1686/.local/share/JetBrains/Toolbox/scripts" "\${PATH}" ];
  };

  # System State
  # This should match the NixOS version you initially installed or upgraded to.
  # Do not change this simply to upgrade NixOS. Instead, use 'nixos-rebuild switch --upgrade'.
  system.stateVersion = "25.05";
}
