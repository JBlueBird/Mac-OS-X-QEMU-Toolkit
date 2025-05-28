#!/bin/bash

# === CONFIGURATION ===

SCRIPT_PATH="$(cd "$(dirname "$0")" && pwd)" #Detect the dir the project is in so it will always work

ISO_IMAGE="$BASE_DIR/mount-me.iso"  # mount an ISO file if you want
BASE_DIR="$SCRIPT_PATH"
DISK_IMAGE="$BASE_DIR/system/host_drive.dmg"
MOUNT_POINT="$BASE_DIR/system/host_mnt"
EXPORT_COPY_DIR="$BASE_DIR/export_from_guest"
IMPORT_SOURCE_DIR="$BASE_DIR/import_to_guest" # <- Put files here to send to the guest
LOG_FILE="$BASE_DIR/system/vm_boot.log"  # <--- The Log file path

SIZE_MB=3000 # Change if you want more space

exec > >(tee "$LOG_FILE") 2>&1 # Start logging everything for debugging in system/vm_boot.log

# === Step 1: Create the writable disk if it doesn't exist ===

if [ ! -f "$DISK_IMAGE" ]; then
  echo "📦 Creating writable HFS+ disk image..."
  hdiutil create -size ${SIZE_MB}m -fs HFS+ -volname HOST -ov "$DISK_IMAGE"
  echo "✅ Disk created at $DISK_IMAGE"

  echo "📁 Creating Import and Export folders..."
  hdiutil attach "$DISK_IMAGE" -mountpoint "$MOUNT_POINT"
  mkdir -p "$MOUNT_POINT/Import"
  mkdir -p "$MOUNT_POINT/Export"
  hdiutil detach "$MOUNT_POINT"
fi

# === Step 2: Sync Import folder from host to disk image ===

mkdir -p "$IMPORT_SOURCE_DIR"
mkdir -p "$MOUNT_POINT"

echo "📤 Updating Import folder on HOST drive from $IMPORT_SOURCE_DIR..."
hdiutil attach "$DISK_IMAGE" -mountpoint "$MOUNT_POINT" -nobrowse

if [ -d "$MOUNT_POINT/Import" ]; then
  rsync -av --delete "$IMPORT_SOURCE_DIR/" "$MOUNT_POINT/Import/"
  echo "✅ Import folder updated."
else
  echo "❌ Import folder not found on HOST drive."
fi

hdiutil detach "$MOUNT_POINT"

# === Sync Mac clipboard into Import/clipboard.txt for guest ===
CLIPBOARD_FILE="$MOUNT_POINT/Import/clipboard.txt"

echo "📋 Copying host clipboard into VM import folder..."
pbpaste > "$CLIPBOARD_FILE"
echo "✅ Clipboard contents saved to Import/clipboard.txt"

# === Step 3: Boot QEMU with this writable disk ===
echo "🚀 Booting Mac OS X 10.4 VM..."

# Build QEMU command array
QEMU_CMD=(
  qemu-system-ppc
  -M mac99,via=pmu
  -cpu G4
  -m 1024 # Beefed up ram for high performance tasks, like loading a webpage
  -hda "$BASE_DIR/system/osx.img"
  -rtc base=localtime # Set the guest clock to the host clock
  -netdev user,id=net0,hostfwd=tcp::2222-:22 \

  # Get high performance networking setup
  -device rtl8139,netdev=net0
  -drive file="$DISK_IMAGE",format=raw,media=disk

  # Add audio drivers

  -audiodev coreaudio,id=snd0
  -device es1370,audiodev=snd0

  # Boot OS

  -boot c
  -prom-env "auto-boot?=true"
)

# Only add -cdrom if the ISO exists
ISO_PATH="$(cd "$(dirname "$0")" && pwd)/$ISO_IMAGE"
if [ -f "$ISO_PATH" ]; then
  echo "📀 ISO found: $ISO_IMAGE — will be mounted as CD-ROM."
  QEMU_CMD+=(-cdrom "$ISO_PATH")
else
  echo "⚠️  ISO file not found, skipping CD-ROM mount."
fi

START=$(date +%s) #Start tracking boot time

# Run the VM with all options
"${QEMU_CMD[@]}"

END=$(date +%s) # End tracking boot time and report results
echo "⏱️ Boot time: $((END - START)) seconds"


echo "🛑 VM shut down."


# === Detect macOS version ===

mkdir -p "$MOUNT_POINT"
echo "🔍 Detecting guest macOS version..."
hdiutil attach "$DISK_IMAGE" -mountpoint "$MOUNT_POINT" -nobrowse > /dev/null

VERSION_PLIST="$MOUNT_POINT/System/Library/CoreServices/SystemVersion.plist"
if [ -f "$VERSION_PLIST" ]; then
  PRODUCT_VERSION=$(defaults read "$VERSION_PLIST" ProductVersion 2>/dev/null)
  PRODUCT_NAME=$(defaults read "$VERSION_PLIST" ProductName 2>/dev/null)
  echo "🧠 Guest OS: $PRODUCT_NAME $PRODUCT_VERSION"
else
  echo "⚠️ Unable to detect macOS version. SystemVersion.plist not found."
fi

# === Sync Export folder from disk image to host ===

mkdir -p "$EXPORT_COPY_DIR"
mkdir -p "$MOUNT_POINT"

echo "📂 Mounting HOST drive to read Export folder..."
hdiutil attach "$DISK_IMAGE" -mountpoint "$MOUNT_POINT" -nobrowse

if [ -d "$MOUNT_POINT/Export" ]; then
  echo "📥 Syncing exported files..."
  rsync -av "$MOUNT_POINT/Export/" "$EXPORT_COPY_DIR/"
  echo "✅ Exported files available at: $EXPORT_COPY_DIR"
else
  echo "❌ Export folder not found on HOST drive."
fi

hdiutil detach "$MOUNT_POINT"