NOTE: YOU MUST HAVE A MACOS X 10.4 .IMG FILE ALREADY. IF YOU DO, PLACE IT IN THE SYSTEM DIR AND NAME IT "osx.img"

Welcome!

This program is for easily creating and moving files between the host OS and Guest OS in a safe way, because QEMU does not natively support it.

This works by mounting a .dmg to the host OS with two folders:

1. Import
and 2. Export

You can import files to the guest system by dragging files to the "import_to_guest" folder, and the files you dragged there will appear in the guest system in the HOST drive, in the "Import" folder.

The same goes the OPPOSITE way, if you drag files in the guest system to the "Export" folder in the HOST drive, it will appear in the Host OS in the export_from_guest folder.

To get everything working, you must double click the boot.command file to run the OS with the HOST drive installed. This file is also responsible for managing imports and exports. If you distrust this file, you can easily verify the code by right-clicking it, and select open with, and select "TextEdit" (or your favorite code editing program)

Also, if you want to mount an additional ISO file (like a installer) you can do so by dragging in your ISO and naming it "mount-me.iso" and it will mount!

I hope you enjoy my software!

P.S. You can ignore the "system" directory, because that is the directory used by the program.

----------------------------
©Birdie Works '25, all rights reserved.
Software written by JBlueBird (https://github.com/JBlueBird)
