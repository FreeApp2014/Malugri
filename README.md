# Malugri
<img src="https://s.neofetch.win/gh-asset/Malugri.svg" width=256 alt=logo><br />

Malugri is a modular app to play various formats of video game music. So far supported formats are the Nintendo audio formats (powered by [OpenRevolution library](https://github.com/ic-scm/OpenRevolution)). The MalugriPlayer core is made to be portable.

# Malugri Mac
This is an implementation of MalugriPlayer for MacOS devices, using [EZAudio](https://github.com/syedhali/EZAudio) library backend for audio playback, and AVFoundation for conversion features.

## Features

The app supports playing all file formats supported by OpenRevolution and associates itself with formats on macOS, so you can play files by double-clicking them
The conversion feature allows you to encode any AVFoundation-supported format audio file into a looped OpenRevolution file, using either DSPADPCM or PCM16 as the codec.

## Screenshots

<img src="https://s.neofetch.win/gh-asset/screenshots-set.png" alt=screenshots><br />

## Building
### Dependencies
This project uses CocoaPods to ship dependencies. If you don't have it installed, you can visit https://cocoapods.org/#install for information on that. Then, in your project folder run
```
pod install
```
After the pods install, you should open the workspace (`.xcworkspace`) in Xcode (not `.xcodeproj`)

### OpenRevolution
In the source tree of this repository you can find the binary blob `libbrstmcpp.a` which is compiled and tested to work with the current version. However if you like to build the library from source, you can build it into a static library file you can use in the project. Issues related to using untested library versions are not reviewed. Issues related purely to the library should be reported to its issues tab.

## Special Thanks
- [Gianmarco Gargiulo](https://www.gianmarco.ga/) for the logo ( [SVG](https://s.neofetch.win/gh-asset/Malugri.svg) / [PNG 2048px](https://s.neofetch.win/gh-asset/Malugri.svg.png)) and for [Italian localization](https://github.com/FreeApp2014/Malugri/tree/rewrite/Malugri/it.lproj) 
- [IC](https://github.com/ic-scm) for advice on using the library
