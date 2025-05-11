# Commands for interactive sessions
if status is-interactive
    # Commands to run in interactive sessions can go here
end

# System and Configuration Management
alias nixconf 'env VISUAL="code --wait" sudoedit /etc/nixos/configuration.nix'
alias nixrebuild 'sudo nixos-rebuild switch --upgrade'
alias clean "sudo nix-collect-garbage -d; sudo /run/current-system/bin/switch-to-configuration boot"

# Navigation and File Management
alias conf "code /home/ks1686/.config/"

# Convenience Aliases
alias c clear
