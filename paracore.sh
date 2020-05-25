#!/system/bin/sh

# -----------------------------------------------
#     parasite-coreonly-remove.sh  by nooriro
# -----------------------------------------------
# References:
# [1] https://forum.xda-developers.com/pixel-4-xl/how-to/magisk-modules-disabler-booting-magisk-t3990557
# [2] https://github.com/nooriro/parasite/blob/master/parasite.sh
# [3] https://github.com/topjohnwu/Magisk/blob/master/docs/guides.md#root-directory-overlay-system
#
# Thanks: Tulsadiver, osm0sis, and topjohnwu
# -------------------------------------------------------------------------------------
# Usage: (1) Make sure 'magisk_patched.img' exists in   /sdcard/Download
#        (2) Download latest (or 19.4+) Magisk zip into /sdcard/Download
#        (3) Place this script in /data/local/tmp (or ~) and set execution permission
#        (4) Run this script
# -------------------------------------------------------------------------------------


MAGISKPATCHEDIMG=$( ls -1 /sdcard/Download/magisk_patched.img 2>/dev/null )
if [ -z "$MAGISKPATCHEDIMG" ]; then
  echo "! magisk_patched.img does not exist in /sdcard/Download" 1>&2
  exit 1
else
  echo "* Magisk patched boot image: [${MAGISKPATCHEDIMG}]" 1>&2
fi

MAGISKZIP=$( ls -1 /sdcard/Download/Magisk-v[1-9][0-9].[0-9].zip \
  /sdcard/Download/Magisk-v[1-9][0-9].[0-9]\([1-9][0-9][0-9][0-9][0-9]\).zip \
  2>/dev/null | tail -n 1 )
if [ -z "$MAGISKZIP" ]; then
  echo "! Magisk zip does not exist in /sdcard/Download" 1>&2
  exit 2
else
  echo "* Magisk zip:                [${MAGISKZIP}]" 1>&2
  echo "* Magisk zip version:        [${MAGISKZIP:25:4}]" 1>&2
  MAGISKZIPVER="${MAGISKZIP:25:2}${MAGISKZIP:28:1}"
  if [ "$MAGISKZIPVER" -lt 194 ]; then
    echo "! Magisk zip version is less than 19.4" 1>&2
    exit 3
  fi
fi

function echomsg() {
  local EUID=$( id -u )
  if [ "$EUID" = "2000" ]; then
    echo "$1$2" 1>&2
  else
    echo "$1" 1>&2
  fi

}

function parasite() {
  if [ "$1" = "coreonly" ]; then
    # ---------- start of overlay files contents (coreonly) ----------
    # overlay.d  ('coreonly')
    # ├── init.resetmagisk.rc        4137f9f7    3b0048ac4d95d0a9a5001c147f33fc0b1156fc0f
    # └── sbin
    #     └── init.resetmagisk.sh    12f2ef07    0235b041c72d45c8dd937bef71b37f6c6cc5c937
    # 
    local INIT_RESETMAGISK_RC='on post-fs-data
    exec u:r:magisk:s0 root root -- /sbin/init.resetmagisk.sh
'
    local INIT_RESETMAGISK_SH='#!/system/bin/sh
> /cache/.disable_magisk
> /data/cache/.disable_magisk
'
    # ---------- end of overlay files contents (coreonly)----------
  elif [ "$1" = "remove" ]; then
    # ---------- start of overlay files contents (remove) ----------
    # overlay.d  ('remove')
    # ├── init.resetmagisk.rc        4137f9f7    3b0048ac4d95d0a9a5001c147f33fc0b1156fc0f
    # └── sbin
    #     └── init.resetmagisk.sh    c66946c3    596ff1fea453a8d6d592612c0fac75f27b31f622
    # 
    local INIT_RESETMAGISK_RC='on post-fs-data
    exec u:r:magisk:s0 root root -- /sbin/init.resetmagisk.sh
'
    local INIT_RESETMAGISK_SH='#!/system/bin/sh
rm -rf /data/adb/* && reboot
'
    # ---------- end of overlay files contents (remove) ----------
  else
    return 1
  fi
  
  local PWD_PREV=$PWD
  local DIR=$( mktemp -d 2>/dev/null )
  [ -z "$DIR" ] && DIR=$( mktemp -d -p "$( dirname $0 )" )
  cd "$DIR"
  
  echomsg "- Extracting Magisk zip" "                           (unzip)"
  unzip "$MAGISKZIP" >/dev/null
  if [ ! -f "arm/magiskboot" ]; then
    echo "! magiskboot does not exist in Magisk zip" 1>&2
    cd "$PWD_PREV"
    rm -rf "$DIR"
    exit 4
  fi
  chmod u+x arm/magiskboot
  
  echomsg "- Dropping overlay files" "                          (printf & redirection)"
  if [ "$1" = "coreonly" ]; then
    printf "%s" "$INIT_RESETMAGISK_RC" > init.resetmagisk.rc
    printf "%s" "$INIT_RESETMAGISK_SH" > init.resetmagisk.sh
  elif [ "$1" = "remove" ]; then
    printf "%s" "$INIT_RESETMAGISK_RC" > init.resetmagisk.rc
    printf "%s" "$INIT_RESETMAGISK_SH" > init.resetmagisk.sh
  fi
  
  echomsg "- Unpacking magisk_patched.img" "                    (magiskboot unpack)"
  ./arm/magiskboot unpack /sdcard/Download/magisk_patched.img 2>/dev/null
  
  echomsg "- Inserting overlay files into ramdisk.cpio" "       (magiskboot cpio)"
  if [ "$1" = "coreonly" ]; then
    ./arm/magiskboot cpio ramdisk.cpio \
      "mkdir 755 overlay.d" \
      "add 644 overlay.d/init.resetmagisk.rc init.resetmagisk.rc" \
      "mkdir 755 overlay.d/sbin" \
      "add 744 overlay.d/sbin/init.resetmagisk.sh init.resetmagisk.sh" 2>/dev/null
  elif [ "$1" = "remove" ]; then
    ./arm/magiskboot cpio ramdisk.cpio \
      "mkdir 755 overlay.d" \
      "add 644 overlay.d/init.resetmagisk.rc init.resetmagisk.rc" \
      "mkdir 755 overlay.d/sbin" \
      "add 744 overlay.d/sbin/init.resetmagisk.sh init.resetmagisk.sh" 2>/dev/null
  fi
  
  echomsg "- Repacking boot image" "                            (magiskboot repack)"
  ./arm/magiskboot repack /sdcard/Download/magisk_patched.img 2>/dev/null
  
  echomsg "- Copying new boot image into /sdcard/Download" "    (cp)"
  cp new-boot.img /sdcard/Download/magisk_patched_$1.img 2>/dev/null
  
  echo "* New patched boot image:    [/sdcard/Download/magisk_patched_$1.img]" 1>&2
  local SHA1_ORIG=$( ./arm/magiskboot cpio ramdisk.cpio sha1 2>/dev/null )
  echo "* Stock boot image SHA1:     [${SHA1_ORIG}]" 1>&2
  
  cd "$PWD_PREV"
  rm -rf "$DIR"
  return 0
}

parasite coreonly
parasite remove

# echo 1>&2
sha1sum /sdcard/Download/boot.img /sdcard/Download/magisk_patched.img 1>&2
sha1sum /sdcard/Download/magisk_patched_coreonly.img
sha1sum /sdcard/Download/magisk_patched_remove.img
rm "$0"
exit 0
