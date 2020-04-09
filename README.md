# Malugri
A native BRSTM player Cocoa app for macOS. Based on [Extrasklep's librevolution C++ BRSTM library](https://github.com/Extrasklep/revolution)

## Usage
This app associates with *.brstm files on your system so files can be played by double clicking in Finder.
The player will loop files that have `HEAD1_loop` flag automatically. This behavior can be changed using the *Looping* checkbox in the main UI.
The app supports playing files by fully decoding them to RAM or by streaming from disk (using `brstm_fstream_getbuffer`). In *Automatic* mode it will getbuffer for files bigger than 5 MB and full decode for smaller files.

## Work-in-Progress features
* Encoding normal audio to loopable BRSTM
* Converting BRSTM files to WAV

## Not yet available features
* Editing existing file headers

## Future features
* Integration with [SCM Archive](https://smashcustommusic.net)

## Screenshot
 ![main window screenshot](https://scr.freeappsw.space/malugriappgh.png)
