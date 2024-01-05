#!/bin/bash
# -*- mode: shell-script; indent-tabs-mode: nil; sh-basic-offset: 4; -*-
# ex: ts=8 sw=4 sts=4 et filetype=sh

depends() {
    echo clevis
}

install() {
    dracut_install awk

    inst_script "${moddir}/clevis-luks-generic-unlocker-wrapper" \
        "/usr/bin/clevis-luks-generic-unlocker"

    # The dracut modules `clevis` will install a systemd unit that responds to password prompts of the kind generated by systemd-cryptsetup. However, systemd-cryptsetup 
    # generates units based on /etc/crypttab. To make /etc/crypttab available in the initramfs with the correct entries, we would have to rebuild a new initramfs which 
    # includes the updated /etc/crypttab after the first boot during which Ignition set up disk encryption. But we do not do that. 
    # The dracut module `clevis` runs the clevis-luks-generic-unlocker script as a dracut hook, but only if dracut is used without systemd. Since we use systemd
    # the `clevis` dracut module does not set up this hook.
    # Hence, our solution is to add a custom dracut module that adds a systemd unit that runs the clevis-luks-generic-unlocker script.
    inst_simple "${moddir}/clevis-unlock.service" \
        "${systemdsystemunitdir}/clevis-unlock.service"
    
    systemctl --root "$initdir" enable clevis-unlock.service
}
