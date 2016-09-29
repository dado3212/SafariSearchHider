# <img src="/safarisearchhider/Resources/icon@2x.png?raw=true" width="30" alt="Logo"/> SafariSearchHider

SafariSearchHider is a Cydia tweak that adds the options to create regex or wildcard strings that will 
not be saved in Safari search history.

### Installation

To install it, either install from the .deb, or add the repository http://cydia.alexbeals.com to Cydia and download SafariSearchHider.

### Modification

To start modifying it, simply copy the full folder in, and then symlink folders called 'theos' to $(THEOS) in both the preferences folder and the main folder.  You can create and install the tweak using 'make package install'.

You'll also need a custom set of `include` files in the $(THEOS) directory, which I will update this with at a later date.  I used the iOS8.1 SDK to maintain backwards compatability.

---

<ul>
  <li>
  Objective-C
  <ul>
  <li>THEOS</li>
  </ul>
  </li>
</ul>

**Created by Alex Beals © 2015**
