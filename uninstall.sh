#!/bin/sh

stop() {
    printf %s\\n "Uninstall error: $1" >&2
    exit 1
}

root_id=0
user_id=$(id -u)
if [ "$user_id" -ne "$root_id" ]; then
    stop 'this script should be run as root, sudo ./uninstall.sh'
fi

command -v grub-mkconfig >/dev/null || stop "GRUB setup not supported"

grub_control=/etc/default/grub
grub_config_file=/boot/grub/grub.cfg
[ -r "$grub_control" ] || stop "cannot read $grub_control"
[ -r "$grub_config_file" ] || stop "cannot read $grub_config_file"

posix_sed() {
    # $1: sed expression, $2: target file
    sed "$1" "$2" > tmp.txt && mv tmp.txt "$2"
    [ "$?" -eq 0 ] || stop 'could not perform replacement.'
}

posix_sed '/GRUB_THEME/s,^.*$,#GRUB_THEME="mytheme",' "$grub_control" 2>/dev/null
rm -r "/usr/share/grub/themes/evodevo" 2>/dev/null

grub-mkconfig -o "$grub_config_file" || stop 'could not reconfigure GRUB.'

printf %s\\n "Theme uninstalled."

