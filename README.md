# UltiboTTF Demo Application

This is a demonstration application for loading of TrueType fonts in an Ultibo application. It demonstrates how to use my TFontConverter class to load TTF fonts from disk without going through any external conversion process.

Prior to building this class, any required fonts not already provided by Ultibo needed to be compiled into your application using constant arrays of data which in turn would be produced by an external font converter application called 'font2openvg'.

When using this class, this is no longer required. Simply nominate a folder on your SD card to store the TTF files in and install the fonts there. Then initialise a TFontManager instance and call its GetFont() method to load a font and it will return you a PVGShapesFontInfo pointer for use with OpenVG. As with everything else in OpenVG Fonts are layer specific so you must ensure you have the layer selected you will be using the fonts on before calling GetFont(). In addition, you must call GetFont() for each layer you want to use the font on.  The demo application demonstrates this.

Note that all of the clever stuff is found in a submodule 'fontman'. If you clone this repo in the normal way you will not automatically get the submodule. Use the following command instead:

```
git clone --recurse-submodules https://github.com/ric355/ultibottf.git
```

You can then open the project in the Lazarus Ultibo edition and it should build.

## Installation
* Create a folder on your sd card in the root called 'fonts'.
* Copy the demo ttf files from this repo to the fonts folder you just created.
* Copy the kernel image to your sd card.
* Ensure the other relevant Ultibo boot files are all present.
* Reboot your device.

## Demo operation
The demo application scans the font folder for available fonts and loops through them all writing a message on the screen in the font. If you telnet to your device and use "update get file <filename> /c" while in the c:\fonts directory to add a new .ttf file. The application will spot any new files while running, convert them, and add them to the display loop.

The demo application compiles one font in directly which it displays initially, showing that both internal and external fonts can coexist.

Note that complex fonts can be very memory intensive and may take 2-3 seconds to convert. Most fonts are a lot quicker than that though.

The demo application does not have build configurations for all Pi versions. It is set up for a Pi3 (and hence Zero2w) only. If you want to run on a different device you will need to tweak it appropriately.  It uses OpenVG so it won't work on a Pi4 at all.

# Licensing
See the fontman repo for information on licensing of the fontconv.pas file, as it is a deriviative of somone else's work.

The fonts packaged with this example originated from https://www.1001freefonts.com, although they were renamed to make them easier to transfer using 'update get file'. They are free for personal use only so ok for compiling and running the demo but for commercial use they must be licensed.
