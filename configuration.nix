{ config, pkgs, ... }:

{
  # =========================================================================
  # IMPORTS
  # =========================================================================
  imports = [
    ./hardware-configuration.nix # Hardware-specific settings
  ];

  # =========================================================================
  # CORE SYSTEM SETTINGS
  # =========================================================================

  # Bootloader
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # LUKS Encryption
  boot.initrd.luks.devices."luks-09124d87-d012-4b1d-8f86-037db7f25b8b".device =
    "/dev/disk/by-uuid/09124d87-d012-4b1d-8f86-037db7f25b8b"; # LUKS partition

  # Nix Configuration
  nix.settings = {
    auto-optimise-store = true;
  };
  nixpkgs.config = {
    allowUnfree = true; # Allow non-free packages
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
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
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

  # =========================================================================
  # SERVICES & DESKTOP ENVIRONMENT
  # =========================================================================

  # X11 Server & Desktop Environment
  services = {
    xserver = {
      enable = true; # Enable X11 windowing system
      videoDrivers = [ "nvidia" "amdgpu" ]; # X server graphics drivers
      xkb = {
        # Xorg keyboard layout
        layout = "us";
        variant = "";
      };
    };
    displayManager.sddm.enable = true;
    desktopManager.plasma6.enable = true;
  };
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
    ];
    shell = pkgs.fish;
    packages = with pkgs.kdePackages; [
      kate # Editor
      sweeper # User cleaning tool
      skanpage # Scan images
      sddm-kcm # Edit SDDM using KDE
      plasma-thunderbolt # Manage thunderbolt devices
      partitionmanager # Manage disk devices, partitions, and file systems
      okular # Document viewer
      kwave # Sound editor
      kleopatra # GUI for OpenPGP
      kjournald # Monitor systemd-journald
      keysmith # OTP client
      kdenlive # Open source video editor
      isoimagewriter # Write ISO to devices
      gwenview # Image viewer
      ghostwriter # Markdown
      elisa # Music player
      calligra # Office and graphic art suite
    ];
  };

  # =========================================================================
  # FONTS
  # =========================================================================
  fonts.packages = with pkgs; [
    nerd-fonts.hack # Hack nerd font mono
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

  programs.fish = {
    enable = true; # You already have this
    shellInit = ''
      # User-specific settings for ks1686
      if test "$USER" = "ks1686"
        fish_config prompt choose astronaut
        set -U fish_greeting ""

        # Aliases
        alias c "clear"
        alias nixconf "kate /etc/nixos/configuration.nix"
        alias nixbuild "sudo nixos-rebuild switch --upgrade"
        alias nixclean "sudo nix-collect-garbage -d; sudo /run/current-system/bin/switch-to-configuration boot"
        alias mount_umbrel 'sudo mount -t cifs "//umbrel.emerald-themis.ts.net/karim smires\'s umbrel" ~/Umbrel -o credentials=/home/ks1686/.smbcredentials_umbrel,uid=$(id -u),gid=$(id -g),iocharset=utf8,nofail'
        alias umount_umbrel "sudo umount ~/Umbrel"
      end
    '';
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
    # --- AI and ML ---
    cudatoolkit
    opencv

    # --- Browsers ---
    google-chrome

    # --- Creation ---
    blender # 3D model creation suite
    freecad-wayland # 3D CAD modeler
    krita # Painting application
    obs-studio # Video recording/streaming utility
    prusa-slicer # 3D printing slicer

    # --- Communication ---
    betterdiscordctl # BetterDiscord manager
    discord # Discord client

    # --- Gaming ---
    heroic # Epic Games, GOG, and Amazon Launcher
    itch # Itch.io client
    prismlauncher # Minecraft mod launcher

    # --- IDE ---
    android-studio # Android
    jetbrains.clion # C/C++
    jetbrains.idea-ultimate # Java
    jetbrains.rider # .NET
    jetbrains.rust-rover # Rust
    jetbrains.webstorm # JavaScript

    # --- Programming Languages ---
    # .NET
    dotnet-sdk
    mono
    # C/C++
    gcc
    # JVM
    gradle
    openjdk
    # NodeJS
    nodejs
    pnpm
    nodePackages.prettier
    # Python
    python3
    ruff
    uv
    # Rust
    cargo
    rustc
    # Typescript
    typescript


    # --- System ---
    aria2 # Download utility
    bottles # Windows application managers
    dxvk # DirectX to Vulkan translation
    fsearch # File search utility
    fwupd # Firmware information
    gearlever # AppImage Manager
    hunspell # Spell checker
    hunspellDicts.en-us-large # English dictionary
    lazydocker # TUI for Docker
    rm-improved # Safer 'rm'
    sirikali # Encryption tool
    supergfxctl-plasmoid # Plasma integration for supergfxctl
    tealdeer # TLDR in Rust
    qemu # Machine virtualisation and emulation
    quickemu # Fast virtual machines
    quickgui # GUI for quickemu
    wineWowPackages.stable # Wine (32-bit and 64-bit)
    yt-dlp # Video downloader
  ];
}
