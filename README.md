# Grub EvoDevo

Grub EvoDevo is a highly configurable GRUB theme with scalable graphics,
background blurring, and antialiased true-type fonts. EvoDevo can use any
wallpaper as background, and more than **40 theme parameters** (e.g., menu size,
placement, color, transparency, and amount of blurring) can be customized.

EvoDevo allows you to **rename your menu entries**, and does it perfectly safely
because only the visual display changes (the real entries stay unaffected). In
all cases, the install script auto-detects menu entries and decorates them with
the corresponding emblem. If a distro is not recognized, it is assigned a
hashbang (#) as emblem.

EvoDevo also allows you to **preview your theme** without rebooting and without
needing to install a virtual machine. EvoDevo's preview facility speeds up the
configuration process considerably.

![example-narrow](example-narrow.jpg)

![example-wide](example-wide.jpg)

![example-maximal](example-maximal.jpg)

# Won't, don't

- EvoDevo **will not install on Fedora**, or more generally, any distribution
that relies on `grub2-mkconfig` (instead of `grub-mkconfig`) for GRUB updates.

- If your booting process involves a
[Unified Kernel Image](https://wiki.gentoo.org/wiki/Unified_kernel_image) (UKI),
then EvoDevo's GRUB menu, although fully functional, will look **partially or
totally empty**.

TLDR: Do not install EvoDevo on a system with UKI.


# Dependencies

Aside from a functional POSIX system, EvoDevo requires:

- **rsvg-convert** or **Inkscape** to convert SVG documents to PNG images.

The rsvg-convert utility is less known, but more lightweight, than Inkscape. If
you choose to install `rsvg-convert`, look for a package named along the lines
of `librsvg` or `librsvg2`.

- **ImageMagick** or **GraphicsMagick** to process your wallpaper picture,
assuming you use one.

If you prefer your screen background to be a single color (e.g., purple)
instead of a wallpaper picture, then having ImageMagick or GraphicsMagick
installed is not necessary.


# Installation

- **Create a directory** (say, "evodevo") somewhere on your computer.

- Scroll back to the top of this page and have a look at the file tree.  One of
the files is a zip archive called, **evodevo.zip**. Right-click on this file to
open a context menu, and choose the "**Open Link in New Tab**" option. GitHub
will allow you to download the archive by clicking on the **Raw** button or
the associated download icon.

- Once evodevo.zip saved on your computer, put it in the directory you just created,
and **unpack the archive** with `unzip evodevo.zip`. This will provide you with two
shell scripts, `install.sh` and `uninstall.sh`, and three subdirectories, `data/`,
`images/`, and `wallpapers/`.

- Also make sure that the install and uninstall scripts are executable (`chmod u+x
 install.sh uninstall.sh`).

## Note

The `data/` subdirectory contains the SVG data needed to draw distro emblems.
The `images/` subdirectory will allow you to add up to two custom images to
the screen. The `wallpapers/` subdirectory contains the default wallpaper.


# Basic configuration

To configure the install script, you will need to know the width and height
of your screen in pixels **at boot time**. These values must be those used by
GRUB before your graphic driver is loaded, so **do not try to read them from
your desktop environment**.

Instead, **reboot your computer**, and type `c` when the GRUB menu shows up. This
will open a command line with a prompt (`>`). Type `videoinfo` [Enter], and GRUB
will print a list of screen resolutions. The one used at boot time **is prefixed
by an asterisk** (*). For example, with this list:

```
  0x000  320 x  200 x 32 (1280)  Direct color, mask: 8/8/8/8  pos: 16/8/0/24
  0x006  320 x  240 x 32 (1280)  Direct color, mask: 8/8/8/8  pos: 16/8/0/24
  0x007  320 x  200 x 32 (2560)  Direct color, mask: 8/8/8/8  pos: 16/8/0/24
* 0x008 1600 x 1200 x 32 (6400)  Direct color, mask: 8/8/8/8  pos: 16/8/0/24
  0x009 1280 x  800 x 32 (5120)  Direct color, mask: 8/8/8/8  pos: 16/8/0/24
```

boot-time resolution is 1600 x 1200 pixels. Whatever this resolution is, take
note of it.

Then, once logged in your system, open `install.sh` in your favorite text
editor. Configuring EvoDevo involves a series of `VARIABLE=VALUE` assignments.
They appear at the start of the install script, in the section titled:

```
# ------------------------------------------------------------
# CONFIGURATION
# ------------------------------------------------------------
```

Each assignment has a default value and is followed by comments (`# ...`)
designed to help you during the configuration process.

The first two assignments, to `ScreenWidth` and `ScreenHeight`, are the most
important ones. **Replace the default values by the values GRUB uses at boot
time** (and that you have just determined).

The third assignment, about `FontSize` in pixels, is important too, as
**everything in the theme is scaled as function of font size**. The default
value, 20, will work well with a screen height of about 1000 pixels. With a
larger screen height (e.g., 2000 pixels), try a larger font size (e.g., 40).

The fourth assignment sets the **background wallpaper**. If you leave this
line as is:

```
Wallpaper='default.jpg'
```

EvoDevo will use the default wallpaper—a picture of the ocean by Magda Ehlers.

If you want to use a custom picture as wallpaper, however, you will need to
**add your picture file** to the `wallpapers/` subdirectory of the install folder,
and you will need to replace `default.jpg` in the install script by the actual
name of your file. For example:

```
Wallpaper='my picture.jpg'
```

A last possibility is to assign to `Wallpaper` **a color name in the #rrggbb
format**. For example, writing the following:

```
Wallpaper='#ba84c2'
```

will make the background of your screen look purple.

Using a single color (instead of a wallpaper picture) as background has
three advantages:

- installation is faster
- it does not require ImageMagick or GraphicsMagick
- it comes in handy if the GRUB
[dislikes your wallpapers](https://bbs.archlinux.org/viewtopic.php?id=279201)

## Note

If you choose to use a wallpaper file, it must be a valid JPEG or PNG picture,
in 8-bit or 16-bit RGB color mode without interlacing.

The width and height of your wallpaper should not necessarily equal those of the
screen at boot time, as the install script will automatically resize your picture
to the correct dimensions. To avoid possible distortions, however, your wallpaper
aspect ratio should preferably match that of the boot-time screen.


# Theme preview

Once done with the `ScreenWidth`, `ScreenHeight`, `FontSize`, and `Wallpaper`
assignments, save the install script, go back to your terminal, and type:

```
./install.sh -preview
```

If everything goes well, the script will conclude with:

```
-----------------------------
preview.png successfully generated!
-----------------------------
```

Opening `preview.png` in your favorite image viewer will then show you **a preview
of the configured theme**. The preview is shown at the size of the screen at boot
time, and for simplicity, the menu displays only one entry (a fake one: "Example
of entry").

If you do **not** see the `preview.png successfully generated!` message, then
something went wrong (and the script will probably tell you what). The worst kind
of error would be to forget to quote a `VALUE WITH BLANKS IN IT` or to forget a
closing quote (as this would wreak havoc on the whole script).

Once you are satisfied with your configuration, type:

```
sudo ./install.sh
```

to **actually install the theme**. If everything goes well, the script will
conclude with:

-----------------------------
Theme installed successfully!
-----------------------------

and Grub EvoDevo will show up on your next reboot.


# Advanced configuration

The install script includes more than 40 parameters besides `ScreenWidth`,
`ScreenHeight`, `FontSize`, and `Wallpaper`. Their usage is explained in the
comments after each assignment line.

Most parameters are graphical. For example, `Image_A`, `Image_A_Left`, and
`Image_A_Top` allow you to **add a custom image** (e.g., an OS logo) to the boot
screen. You just need to put a valid JPEG or PNG file in the images/ subdirectory
of the install folder, assign the name of this file to `Image_A`, and assign two
screen coordinates (in pixels) to `Image_A_Left` and `Image_A_Top`. The image will
appear on the boot screen at the assigned position and at its real size (i.e.,
without rescaling).

A **second custom image** can be added to the boot screen via `Image_B`,
`Image_B_Left`, and `Image_B_Top `

Other parameters are textual. For example, the **title**, as well as the **top
and bottom messages**, of the GRUB menu can be configured.  EvoDevo also allows
you to **rename up to ten menu entries** (or parts of menu entries). To this
end, the install script includes ten variables named:

```
Change_0=
Change_1=
Change_2=
...
Change_9=
```

Changing a menu entry (or portion of menu entry) is as simple as assigning
a `TEXT@REPLACEMENT` value to any of these variables. If you want to change
the "Kubuntu" string into "Kubuntu KDE/Wayland", for example, writing:

```
Change_0='Kubuntu@Kunbuntu KDE/Wayland'
```

will do the job. The left side of the @ symbol is the portion of text to be
replaced, the right side of the @ symbol is the replacement string that you
want.

Theme parameters are ordered in terms of decreasing importance. Proceed from the
top to the bottom of the install script, and change the value of a parameter only
if the need arises.


# Example

Aside from basic wallpaper, menu color, transparency, and blurring customization,
the following screenshot illustrates title renaming, entry renaming, and the use
of a logo as custom image.

![example-config](example-config.jpg)


# Theme maintenance

GRUB does not do font antialiasing natively, so EvoDevo uses a workaround to
achieve non-pixelated menu entries. All of the entries visible in the themed
menu are actually **fake entries** (i.e., antialised PNG images), while the
real entries are hidden behind a copy of the background wallpaper. EvoDevo
also inserts custom classes (i.e., annotations) in `grub.cfg` to tell GRUB
to display the fake entries as menu icons.

Unfortunately, whenever your system overwrites `grub.cfg` (this may happen
on any kernel update, for example), the custom classes are wiped out, causing
the EvoDevo menu to look empty:

![empty-menu](example-empty.jpg)

This may look scary, but GRUB remains fully functional, and after booting as
usual you will be able to restore EvoDevo by re-running `sudo ./install`.

TLDR: **Whenever your distribution updates GRUB**, `sudo ./install.sh` should
be run to **restore the theme to full visibility**.

The theme can be uninstalled at any time by running `sudo ./uninstall.sh`.


# Troubleshooting / FAQ

- **Q**: I am positive **Inkscape is installed**, yet `./install.sh` aborts with
this error message: "`neither rsvg-convert nor Inkscape was detected.`"

- **A**: Your software center may have installed Inkscape with Flatpak or Snap.
Try to uninstall Inkscape, then reinstall it directly via your system package
manager (e.g., `apt` or `pacman`).

- **Q**: When running `install.sh`, I see some messages about a **"deprecated
convert command"**.

- **A**: These messages are warnings from ImageMagick. They are not errors,
however, and they do not impede installation.

- **Q**: I am positive EvoDevo is installed. Yet, **nothing shows up on
reboot**—only the GRUB console.

- **A**: Some distributions hide the GRUB menu by writing the following in
`/etc/default/grub`:

```
GRUB_TIMEOUT_STYLE=hidden
GRUB_TIMEOUT=0
```

To be able to see the themed GRUB menu on reboot, you'll need to edit
`/etc/default/grub` as root (e.g., with `sudo nano`) and change these lines to:

```
GRUB_TIMEOUT_STYLE=menu
GRUB_TIMEOUT=15
```

(The value of 15 seconds is just an example, the idea is to leave enough time
for the non-hidden menu to show up.)

Then reinstall EvoDevo (`sudo ./install.sh`) before rebooting.

- **Q**: I have installed EvoDevo with my custom wallpaper, but the theme does
not load, and instead **another background picture shows up**.

- **A**: This picture is probably a residue of another GRUB customization, left
under the `/boot/grub/` directory. Have a look at what `/boot/grub/` contains. If
some JPEG or PNG file is listed under this directory, move the file out of the way,
or it will interfere with theme installation.

- **Q**: I have checked that **my wallpaper is a valid 8-bit or 16-bit JPEG or PNG**
picture, yet GRUB still complains about "png bits" or "png color range" errors.

- **A**: In a few cases, GRUB may not decode a wallpaper picture correctly. This
is more likely to occur if your wallpaper has a restricted RGB profile with
only a few colors in it. **Try to increase the color range** by adding smooth
gradients to your picture. If everything fails, you may have no other choice
than trying another wallpaper, or giving up on wallpapers entirely (and use
instead a single color as background).

- **Q**: I have installed EvoDevo, but the menu looks slightly ugly, and I see
**some faded text on the right of the screen**.

- **A**: Your wallpaper is not 100% opaque. Open it in Gimp (or any other
similar software) to remove the alpha channel (i.e., transparency).

- **Q**: The themed menu looks fine, but everywhere my distro should appear,
**another distro** appears instead!

- **A**: Some distros (e.g., Linux Mint) have their name replaced by the name
of a parent distro (e.g., Ubuntu) in the GRUB config file. To fix the problem,
look for a line that says:

```
Repair=
```

in the EvoDevo install script. As explained in the comments below this line,
assigning a value to `Repair` allows you to get rid of the parent name and
restore your distro name in its correct form. In the case of Linux Mint
showing up as "Ubuntu," for example, writing:

```
Repair='Ubuntu@Linux Mint'
```

in `install.sh` will do what you want.

- **Q**: I have installed EvoDevo, but the **menu looks empty**.

- **A**: Your system may have completed an automatic update after you installed
the theme, but before rebooting. Try to reinstall EvoDevo, then reboot yet another
time. If the error persists, check whether your system uses UKI (Unified Kernel
Image) for booting. If you do no use any UKI, please open an
[issue](https://github.com/ftonneau/grub-evodevo/issues).


# Link

Further examples of Grub EvoDevo customization can be found on
[OpenDesktop](https://www.gnome-look.org/p/2366327).


# Credits

The default wallpaper is a picture by Magda Ehlers, downloaded from
[pexels](https://www.pexels.com/) on July 12, 2026.

The emblems for Bodhi Linux, OpenSUSE, Parrot OS, Spaced Linux, and Vanilla
OS were downloaded from the corresponding distribution/OS web sites.

The emblems for Apple, Arch, Debian, Fedora, Gentoo, Mint, Ubuntu, Windows,
as well as the camera, cog, memory, and power emblems, were downloaded from
[pictogrammers](https://pictogrammers.com/library/mdi/).

All of the other emblems were downloaded from Wikimedia Commons or custom made.

Emblems were simplified whenever needed to accommodate a reduced display size.


# Thanks

Special thanks to [Loric Brevet](https://github.com/lobre),
[Rubben Christiano](https://github.com/BakaBen),
Erik Koennecke,
[Logansfury](https://github.com/Logansfury),
[Matt Marcuzzo](https://github.com/MattM123),
and David Niklas for their advice or help in testing the theme.


# License

MIT

