if status is-interactive
    # Commands to run in interactive sessions can go here
end

alias nixconf 'env VISUAL="code --wait" sudoedit /etc/nixos/configuration.nix'
alias conf "code /home/ks1686/.config/"
alias clean "sudo nix-collect-garbage -d; sudo /run/current-system/bin/switch-to-configuration boot"
alias c clear
