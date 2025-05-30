# Mac OS X QEMU Toolkit

Note: You need a MacOS X Tiger .img file ready to go. If you have it, place it in the system directory or the code script will NOT work without the VM. Name the .img "osx.img"

Run Mac OS X 10.4 Tiger in QEMU with style — this script sets up a modern Import/Export workflow using a hybrid ISO, so you can transfer files in and out of the VM with ease.

## Features

- Seamless Import/Export folder  
  Share files between host and guest using a hybrid ISO with `Import` and `Export` folders.

- Auto-export after shutdown  
  Automatically syncs files from the VM’s `Export` folder back to your host machine.

- Hybrid ISO creation  
  Fully bootable and usable ISO that mounts in both QEMU and classic macOS.

- Designed for QEMU virtual machines running Mac OS X 10.4 Tiger

## Quick Start

```bash
git clone https://github.com/yourusername/qemu-macosx-tools.git
cd qemu-macosx-tools
./setup.sh
```

Your `host.iso` will be generated automatically and ready to mount in your QEMU VM.

## Requirements

- macOS or Linux host
- QEMU
- `mkisofs` or `genisoimage`

## What’s Inside?

| Script/File     | Description                                  |
|-----------------|----------------------------------------------|
| `setup.sh`      | Builds the hybrid `host.iso` with folders    |
| `export-copy.sh`| Syncs files from the VM's Export folder back |
| `qemu.sh`       | (Optional) Prebuilt QEMU launch script       |

## Folder Layout

Inside the ISO, you’ll find:

```
HOST/
├── Import/
└── Export/
```

## Why This Is Cool

- No need for network file sharing
- Works on real vintage Mac software
- Keeps your Mac OS X 10.4 VM isolated but connected

## Like this project?

Please star the repo to support retro Mac tools!

## License

MIT — do what you want, but credit appreciated.

## Credits

Made by Josiah — inspired by vintage computing and making retro Macs useful again.

## To Do

- [ ] Add file type filtering (e.g. ignore `.DS_Store`)
- [ ] Auto-build ISO on guest shutdown
- [ ] Optional compression for exports
