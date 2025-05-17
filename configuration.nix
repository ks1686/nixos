{ config, pkgs, ... }:

{
  # =========================================================================
  # IMPORTS
  # =========================================================================
  imports = [
    ./hardware-configuration.nix # Hardware-specific settings
    <home-manager/nixos> # Home Manager NixOS module
  ];

  # =========================================================================
  # CORE SYSTEM SETTINGS
  # =========================================================================

  # Bootloader
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    # LUKS Encryption
    initrd.luks.devices."luks-34912701-e81c-43b5-a982-429caa687aab".device =
      "/dev/disk/by-uuid/34912701-e81c-43b5-a982-429caa687aab"; # LUKS partition

    # Enable zswap with recommended settings
    kernelParams = [
      "zswap.enabled=1"
      "zswap.compressor=lz4"
      "zswap.max_pool_percent=20"
    ];
  };

  # Nix Configuration
  nix.settings = {
    auto-optimise-store = true; # Optimize Nix store
    max-jobs = 1; # Parallel build jobs
    cores = 1; # Number of CPU cores
  };
  nixpkgs.config = {
    allowUnfree = true; # Allow non-free packages
    cudaSupport = true; # Enable CUDA support
  };

  # Internationalization & Localization
  time.timeZone = "America/New_York"; # System timezone
  i18n.defaultLocale = "en_US.UTF-8"; # Default locale
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

  # System State
  system.stateVersion = "25.05"; # NixOS version for stateful settings

  # =========================================================================
  # HARDWARE SUPPORT
  # =========================================================================

  # Graphics
  hardware.graphics.enable = true; # General graphics support
  hardware.nvidia = {
    modesetting.enable = true; # Kernel modesetting
    powerManagement.enable = false; # NVIDIA power management (tune for laptops)
    powerManagement.finegrained = false;
    open = true; # Use open-source NVIDIA kernel module
    nvidiaSettings = true; # Install NVIDIA settings application
    package = config.boot.kernelPackages.nvidiaPackages.stable; # Stable NVIDIA drivers
    prime = {
      amdgpuBusId = "PCI:101:0:0"; # AMD GPU bus ID for PRIME
      nvidiaBusId = "PCI:1:0:0"; # NVIDIA GPU bus ID for PRIME
    };
  };

  # Laptop Specific Features
  services.supergfxd.enable = true; # Graphics switching control (e.g., ASUS laptops)
  services.asusd = {
    enable = true; # ASUS laptop specific controls (fans, keyboard)
    enableUserService = true;
  };

  # Bluetooth
  hardware.bluetooth.enable = true; # Enable Bluetooth
  hardware.bluetooth.powerOnBoot = true; # Power on Bluetooth at boot

  # Audio (PipeWire)
  services.pulseaudio.enable = false; # Disable PulseAudio (using PipeWire)
  security.rtkit.enable = true; # Real-time Kit for low audio latency
  services.pipewire = {
    enable = true; # Enable PipeWire media server
    alsa.enable = true; # ALSA support via PipeWire
    alsa.support32Bit = true; # 32-bit ALSA support
    pulse.enable = true; # PipeWire's PulseAudio compatibility
  };

  # Printing
  services.printing.enable = true; # Enable CUPS printing service
  services.printing.drivers = [ pkgs.hplip ]; # HP printer drivers

  # =========================================================================
  # NETWORKING
  # =========================================================================
  networking.hostName = "nixos"; # System hostname
  networking.networkmanager.enable = true; # NetworkManager for connection management
  services.tailscale.enable = true; # Tailscale VPN service

  # Service Discovery (mDNS)
  services.avahi = {
    enable = true; # Enable Avahi daemon
    nssmdns4 = true; # mDNS for IPv4 hostname resolution
    openFirewall = true; # Open firewall for Avahi
  };

  # Backup & Restore
  services.borgbackup.jobs.home = {
    paths = [ "/home/ks1686" ]; # Backup paths
    repo = "/backup/ks1686"; # Backup repository
    compression = "auto,zstd"; # Compression method
    encryption = {
      mode = "repokey"; # Encryption mode
      passCommand = "cat /backup/backup_passphrase.txt"; # Passphrase command
    };
    startAt = "hourly"; # Backup frequency
    exclude = [
      "home/ks1686/Android"
      "/home/ks1686/AppImages"
      "/home/ks1686/Games"
      "/home/ks1686/InvokeAI/models"
      "/home/ks1686/Unity"
      "/home/ks1686/.android"
      "/home/ks1686/.cache"
      "/home/ks1686/.local"
      "/home/ks1686/.steam"
      "/home/ks1686/.vscode/extensions"
      "**/*.tmp"
      "**/*.log"

    ]; # Excluded paths
    prune.keep = {
      hourly = 12; # Keep 12 hourly backups
    };
  };

  # =========================================================================
  # SERVICES & DESKTOP ENVIRONMENT
  # =========================================================================

  # X11 Server & Desktop Environment
  services.xserver = {
    enable = true; # Enable X11 windowing system
    videoDrivers = [
      "nvidia"
      "amdgpu"
    ]; # X server graphics drivers
    xkb = {
      # Xorg keyboard layout
      layout = "us";
      variant = "";
    };
    displayManager.gdm.enable = true; # GDM (GNOME Display Manager)
    desktopManager.gnome.enable = true; # GNOME desktop environment
  };

  # Minimal GNOME Installation
  environment.gnome.excludePackages = with pkgs; [
    epiphany
    gnome-calculator
    gnome-clocks
    gnome-connections
    gnome-maps
    gnome-software
    gnome-text-editor
    gnome-tour
    gnome-user-docs
    gnome-weather
    yelp
  ];

  # Secure Shell (SSH)
  services.openssh.enable = true; # Enable OpenSSH daemon

  # =========================================================================
  # USER MANAGEMENT
  # =========================================================================
  users.users.ks1686 = {
    isNormalUser = true;
    description = "Karim Smires";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
      "kvm"
      "adbusers"
      "video"
    ];
    shell = pkgs.fish;
    linger = true; # Allow user processes to run after logout
    packages = with pkgs; [
      # User-specific packages defined via Home Manager
    ];
  };

  # Home Manager Integration
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "bak";
    users = {
      ks1686 = {
        imports = [ ./home-ks1686.nix ]; # Path to user's Home Manager config
      };
    };
  };

  # =========================================================================
  # SHELL & ENVIRONMENT
  # =========================================================================
  programs.fish.enable = true; # Enable Fish shell system-wide
  environment.variables.EDITOR = "code"; # Default system editor

  # Default Applications (XDG Mimeapps)
  xdg.mime.defaultApplications = {
    "text/plain" = "code";
    "text/x-toml" = "code";
  };

  # =========================================================================
  # FONTS
  # =========================================================================
  fonts.packages = with pkgs; [
    nerd-fonts.adwaita-mono # Adwaita Mono Nerd Font
  ];

  # =========================================================================
  # SYSTEM-WIDE PROGRAM FEATURES
  # =========================================================================
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
  };

  programs.adb.enable = true; # Android Debug Bridge support

  programs.appimage = {
    enable = true; # AppImage support
    binfmt = true; # Direct execution of AppImages
  };

  # =========================================================================
  # VIRTUALIZATION & CONTAINERIZATION
  # =========================================================================
  virtualisation.docker.enable = true; # Enable Docker daemon
  hardware.nvidia-container-toolkit.enable = true; # NVIDIA GPU support for Docker

  # =========================================================================
  # INSTALLED PACKAGES (SYSTEM-WIDE)
  # =========================================================================
  environment.systemPackages = with pkgs; [
    # --- System Utilities ---
    aria2 # Download utility
    fwupd # Firmware update utility
    gnumake # GNU Make
    hunspell # Spell checker
    hunspellDicts.en-us-large # English dictionary
    rm-improved # Safer 'rm'
    rsync # File synchronization
    tlrc # TLDR pages
    qemu # Machine emulator and virtualizer
    quickemu # VM creation utility
    yt-dlp # Video downloader

    # --- Shell Enhancements ---
    lazydocker # TUI for Docker

    # --- GNOME Desktop Utilities & Extensions ---
    dconf-editor # GNOME dconf editor
    gnomecast # Cast to Chromecast
    gnome-boxes # VM manager for GNOME
    gnome-tweaks # GNOME Tweak Tool
    gnomeExtensions.gpu-supergfxctl-switch # Graphics switching extension
    gnomeExtensions.tiling-assistant # Tiling assistant
    gnomeExtensions.arcmenu # Arc Menu
    gnomeExtensions.caffeine # Prevent sleep/screensaver
    gnomeExtensions.clipboard-indicator # Clipboard manager
    gnomeExtensions.dash-to-dock # Dash to Dock
    gnomeExtensions.just-perfection # GNOME Shell tweaks
    gnomeExtensions.night-theme-switcher # Night theme switcher

    # --- General Tools ---
    audacity # Audio editor
    blender # 3D creation suite
    borgbackup # Deduplicating backup tool
    bottles # Windows application manager (via Wine)
    davinci-resolve # Video editing software
    freecad-wayland # 3D CAD modeler
    fsearch # File search utility
    gearlever # AppImage manager
    gparted # Partition editor
    obs-studio # Video recording and streaming
    protonplus # Proton manager for Steam Play
    prusa-slicer # 3D printing slicer
    ytmdesktop # YouTube Music desktop client

    # --- Web Browsers ---
    google-chrome # Google Chrome
    tor-browser # Tor Browser

    # --- Communication Tools ---
    betterdiscordctl # BetterDiscord manager
    discord # Discord client

    # --- Development Environment ---
    # IDEs & General Dev Tools
    android-studio # Android IDE
    jetbrains.clion # CLion (C/C++ IDE)
    jetbrains.idea-ultimate # IntelliJ IDEA Ultimate
    jetbrains.pycharm-professional # PyCharm Professional
    jetbrains.rider # JetBrains Rider (.NET IDE)
    jetbrains.rust-rover # Rust Rover (Rust IDE)
    jetbrains.webstorm # WebStorm (JavaScript IDE)
    # quartus-prime-lite # Intel FPGA development software
    unityhub # Unity game engine hub
    vscode.fhs # Visual Studio Code (FHS env)

    # AI/ML Libraries
    cudatoolkit # CUDA Toolkit
    opencv # OpenCV computer vision library

    # Language Toolchains
    # C/C++
    clang-tools # Clang tooling
    cmake # Build system generator
    gcc # GNU Compiler Collection
    # .NET
    dotnet-sdk # .NET SDK
    mono # Open source .NET Framework
    # JVM
    gradle # JVM build tool
    openjdk # OpenJDK
    # LaTeX
    texlive.combined.scheme-full # Full TeX Live
    # Nix
    nil # Nix Language Server
    nixfmt-rfc-style # Nix code formatter
    # Node.js
    nodejs # Node.js runtime
    pnpm # Node.js package manager
    nodePackages.prettier # Code formatter
    # Python
    python3 # Python 3
    ruff # Python linter/formatter
    uv # Python package installer/resolver
    # Rust
    cargo # Rust package manager
    rustc # Rust compiler
    # TypeScript
    typescript # TypeScript language support

    # --- Gaming Clients & Tools ---
    heroic # Epic Games & GOG launcher
    itch # Itch.io client
    prismlauncher # Minecraft launcher

    # --- Windows Compatibility ---
    dxvk # DirectX to Vulkan translation
    wineWowPackages.stable # Wine (32-bit and 64-bit)
  ];
}
