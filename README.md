# What

This iOS app renames files.

This repository was created to reproduce an issue I was having with permissions to modify files outside an iOS app's sandbox. Its second commit is where I started, the next one is the fix. So it is working now.


# How

@rolodato helped me understand [this article](https://developer.apple.com/documentation/uikit/view_controllers/providing_access_to_directories) in Apple's documentation and together we found a solution.

Essentially what needed to be done was first to prompt the user to pick a **folder** and then show the user **another picker** to select the files to work with. If you don't do this in the described two steps, it doesn't work, and you get a permission denied error. Also you can use bookmarks to save security-scoped URLs for following uses of those directories.

This doesn't seem convenient, I feel it could be avoided somehow.


# Next

Feel free to use this code to see how this works.
If you find a way to avoid having the user pick a folder and then its files on another picker, please let me know by submitting a PR or contacting me, I'd appreciate it.
