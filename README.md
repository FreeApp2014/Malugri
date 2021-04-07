# Malugri
<img src="https://binarythinker.dev/asset/Malugri.svg" width=256 alt=logo><br />
A native Cocoa-based Nintendo VGM format audio player app for macOS. Based on [IC's OpenRevolution library](https://github.com/ic-scm/openrevolution) for format support and uses AVFoundation for playing audio.

## Usage

### Playing files
This app associates with *.brstm, *.bfstm and *.bwav files on your system so files can be played by double clicking in Finder. Or you can launch the app and use the Open dialog.
The player will loop files that have `HEAD1_loop` flag automatically. This behavior can be changed using the *Looping* checkbox in the main UI.
The app supports playing files by fully decoding them to RAM or by streaming from disk (using `brstm_fstream_getbuffer`). In *Automatic* mode it will getbuffer for files bigger than 5 MB and full decode for smaller files.

### Conversion
Malugri can convert BRSTM/BFSTM/BWAV files to int16 PCM WAV files. Using this feature is simple: launch the app, in *File* menu choose *Convert to WAV*. It will first ask you to open the original file then it will decode it and show a save file dialog to save the wav.

## Work-in-Progress features
* Encoding normal audio to loopable BRSTM

## Not yet available features
* Editing existing file headers

## Future features
* Integration with [SCM Archive](https://smashcustommusic.net)

## Screenshot
 ![main window screenshot](https://binarythinker.dev/asset/malugriappgh-old.png)

## Special Thanks
* [Gianmarco Gargiulo](https://www.gianmarco.ga/) for the logo ( [SVG](https://binarythinker.dev/asset/Malugri.svg) / [PNG 2048px](https://binarythinker.dev/asset/Malugri.svg.png))
