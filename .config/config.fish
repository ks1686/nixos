alias c clear
alias fishconf 'code ~/.config/fish/config.fish'
alias mount_umbrel 'sudo mount -t cifs "//umbrel.emerald-themis.ts.net/karim smires\'s umbrel" ~/Umbrel -o credentials=/home/ks1686/.smbcredentials_umbrel,uid=(id -u),gid=(id -g),iocharset=utf8,nofail'
alias umount_umbrel 'sudo umount ~/Umbrel'

set -gx EDITOR /usr/bin/nano
set -gx VISUAL /usr/bin/nano
