#!/bin/bash
set -e

echo "================================================="
echo "           Nyx build script"
echo "================================================="
echo

echo "[*] Performing basic sanity checks..."

if [ ! "`uname -s`" = "Linux" ]; then

  echo "[-] Error: Nyx mode is only available on Linux."
  exit 0

fi

echo "[*] Making sure all Nyx is checked out"

git status 1>/dev/null 2>/dev/null
if [ $? -eq 0 ]; then
  git submodule init || exit 1
  echo "[*] initializing QEMU-Nyx submodule"
  git submodule update ./QEMU-Nyx 2>/dev/null # ignore errors
  echo "[*] initializing packer submodule"
  git submodule update ./packer 2>/dev/null # ignore errors
  echo "[*] initializing libnyx submodule"
  git submodule update ./libnyx 2>/dev/null # ignore errors

else
  echo "[ ] not a git repo..."
  exit 1
fi

test -d QEMU-Nyx || { echo "[-] Not checked out, please install git or check your internet connection." ; exit 1 ; }
test -d packer || { echo "[-] Not checked out, please install git or check your internet connection." ; exit 1 ; }
test -d libnyx || { echo "[-] Not checked out, please install git or check your internet connection." ; exit 1 ; }

echo "[*] checking packer init.cpio.gz ..."
if [ ! -f "packer/linux_initramfs/init.cpio.gz" ]; then
    cd packer/linux_initramfs/
    sh pack.sh
    cd ../../
fi

echo "[*] Checking libnyx ..."
if [ ! -f "libnyx/libnyx/target/release/liblibnyx.a" ]; then
    cd libnyx/libnyx
    cargo build --release
    cd ../../
fi

echo "[*] Checking QEMU-Nyx ..."
if [ ! -f "QEMU-Nyx/x86_64-softmmu/qemu-system-x86_64" ]; then
    cd QEMU-Nyx/
    ./compile_qemu_nyx.sh
    cd ..
fi

echo "[*] Checking libnyx.so ..."
if [ -f "libnyx/libnyx/target/release/liblibnyx.so" ]; then
  cp libnyx/libnyx/target/release/liblibnyx.so libnyx.so
  cp libnyx/libnyx/target/release/liblibnyx.so ../libnyx.so
else
  echo "[ ] libnyx.so not found..."
  exit 1
fi
echo "[+] All done for nyx_mode, enjoy!"

exit 0