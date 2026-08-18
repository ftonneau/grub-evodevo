#!/bin/sh

# ------------------------------------------------------------
# CONFIGURATION
# ------------------------------------------------------------

# This section of the script is a series of VARIABLE=VALUE assignments. There
# should be no spaces around the equal sign. If VALUE includes blanks, surround
# VALUE with quotes. For example:

# Wallpaper='my favorite picture.png'

# The lines starting with '#' are comments to help you with the assignments.

ScreenWidth=1920
ScreenHeight=1080
# Width and height (in pixels) of your screen at boot time. These values
# must be those actually used by GRUB, so do not try to read them from your
# desktop environment. Instead, reboot your computer, and type 'c' when the
# GRUB menu shows up. This will open a command line with a prompt ('>'). Type
# 'videoinfo' [Enter], and GRUB will print a list of resolutions. The one used
# at boot time is prefixed with an asterisk (*). For example, with this list:

#   0x000  320 x  200 x 32 (1280)  Direct color, mask: 8/8/8/8  pos: 16/8/0/24
#   0x001  640 x  480 x 32 (2560)  Direct color, mask: 8/8/8/8  pos: 16/8/0/24
#   0x006  320 x  240 x 32 (1280)  Direct color, mask: 8/8/8/8  pos: 16/8/0/24
#   0x007  320 x  200 x 32 (2560)  Direct color, mask: 8/8/8/8  pos: 16/8/0/24
# * 0x008 1600 x 1200 x 32 (6400)  Direct color, mask: 8/8/8/8  pos: 16/8/0/24
#   0x009 1280 x  800 x 32 (5120)  Direct color, mask: 8/8/8/8  pos: 16/8/0/24

# boot-time resolution is 1600 x 1200, and you should set ScreenWidth and
# ScreenHeight to 1600 and 1200, respectively.

FontSize=20
# Font size in pixels. The default value, 20, works well with a screen height
# of about 1000 pixels. With a larger screen height (e.g., 2000 pixels), try
# a larger font size (e.g., 40).

Wallpaper='default.jpg'
# Name of the JPG or PNG file to use as wallpaper. *Put this file in the
# wallpapers/ subdirectory of the install folder, otherwise the file will
# not be detected.*

MenuStyle=narrow
# Possible values are 'narrow' and 'wide'. With MenuStyle=narrow, the menu has
# rounded corners, the header can be colored differently, and entries extend all
# the way to menu borders. With MenuStyle=wide, the menu has square corners and
# the header cannot be colored differently; menu entries are rounded and have
# wider margins.

XPercent=center
YPercent=center
# Percent-of-screen values (without the % sign) for the X and Y coordinates of
# the menu. For example, XPercent=30 will position the menu at 30% of screen
# width. Using 'center' as value leaves the menu centered on the screen.

MenuPercent=60
# Menu width as percentage of screen width; do not include the % sign. Set this
# percentage wide enough to avoid truncating menu entries.

MenuCapacity=6
# Menu capacity in entries (i.e., maximum number of entries visible on the
# screen). If more entries are available, Grub will allow you to scroll down
# the menu with arrows.

MenuBg='200 10 10'
HeaderBg='200 0 10'
FocusBg='185 10 40'
TextFg='0 0 100'
IconFg='0 0 85'
BarBg='0 0 100'
BarFg='185 10 10'
# Values of menu background, header background, entry focus, text color, icon
# color, progress-bar background, and progress-bar foreground. Each value is
# expressed as 'H S L' (quoted and blank separated), with H = hue from 0 to
# 360, S = saturation from 0 to 100, and L = lightness from 0 to 100. Note:
# HeaderBg applies only for MenuStyle=narrow.

MenuOpacity=0.75
HeaderOpacity=0.90
FocusOpacity=0.80
# Opacity values for the menu, the header, and the background of the focused
# entry. Each value is a floating-point number from 0 (full transparency) to
# 1 (full opacity). Note: HeaderOpacity applies only for MenuStyle=narrow.

Sigma=20
# This value is the amount, in pixels, of wallpaper blurring behind the menu.
# A value of 0 means no blurring.

FontFamily='Sans'
# Any true-type font installed on your system. Example: 'Roboto Mono'.

Title='Boot Menu'
EnterMsg='[ Enter  Accept ]'
CommandMsg='[ e  Edit   |   c  Console ]'
# These menu messages can be freely customized, provided you avoid characters
# such as quotes, <, and &. You can use successive blanks to increase spacing
# betwen words.

MemoryRegex='memory|memtest'
PowerRegex='halt|reboot|shutdown'
SnapshotRegex='snapshot'
SystemRegex='bios|firmware|setting|setup|uefi'
# These are regular expressions, used to detect different types of menu-entry
# emblems.

# ------------------------------------------------------------
# END OF CONFIGURATION
# ------------------------------------------------------------

# ***Do not change anything below this line.***

# PROGRAM START

stop() {
    printf %s\\n "Install stopped: $1" >&2
    exit 1
}

root_id=0
user_id=$(id -u)
if [ "$user_id" -ne "$root_id" ]; then
    stop 'this script should be run as root, sudo ./install.sh'
fi

command -v grub-mkconfig >/dev/null || stop "GRUB setup not supported"

grub_control=/etc/default/grub
grub_config_file=/boot/grub/grub.cfg
[ -r "$grub_control" ] || stop "cannot read $grub_control"
[ -r "$grub_config_file" ] || stop "cannot read $grub_config_file"

if command -v gm >/dev/null; then
    change='gm convert'
    smooth='gm mogrify -blur'
elif command -v convert >/dev/null; then
    change='convert'
    smooth='mogrify -blur'
else
    stop 'neither GraphicsMagick nor ImageMagick was detected.'
fi

if command -v rsvg-convert >/dev/null; then
    png_make='rsvg-convert -o tmp.png'
elif command -v inkscape >/dev/null; then
    png_make='inkscape --export-type=png'
else
    stop 'neither rsvg-convert nor Inkscape was detected.'
fi

theme_path=/usr/share/grub/themes/evodevo
theme_file="${theme_path}/theme.txt"
icons_path="${theme_path}/icons"

rm -r "$theme_path" 2>/dev/null
mkdir -p "$theme_path"
mkdir -p "$icons_path"

# DEFINITIONS

MenuWidth=$((ScreenWidth * MenuPercent / 100))
if [ "$MenuStyle" = narrow ]; then
    LeftMargin=0
    RightMargin=0
else
    LeftMargin=$((FontSize * 15/10))
    RightMargin=$((FontSize * 15/10))
fi
PanelWidth=$((LeftMargin + MenuWidth + RightMargin))

if [ "$MenuStyle" = narrow ]; then
    TopMargin=$((FontSize * 35/10))
    BottomMargin=$((FontSize * 32/10))
else
    TopMargin=$((FontSize * 60/10))
    BottomMargin=$((FontSize * 50/10))
fi
ItemSquare=$((FontSize * 22/10))
[ $((ItemSquare % 2)) -eq 1 ] && ItemSquare=$((ItemSquare + 1))
ItemSpacing=2
ItemRoom=$((ItemSquare + ItemSpacing))
MenuHeight=$((MenuCapacity * ItemRoom - ItemSpacing))
PanelHeight=$((TopMargin + MenuHeight + BottomMargin))

if [ "$MenuStyle" = narrow ]; then
    TopLevel=$((FontSize * 15/10))
    HeaderHeight=$((FontSize * 28/10))
else
    TopLevel=$((TopMargin / 2))
    HeaderHeight=$TopMargin
fi
TopNavLevel=$((TopLevel - ItemSquare / 2))
BottomLevel=$((PanelHeight - BottomMargin / 2))
BottomNavLevel=$((BottomLevel - ItemSquare / 2))

Tab=$((ItemSquare / 2))
EntryTab=$((Tab + ItemSquare + Tab))

NavTab=$((LeftMargin + Tab))
TitleTab=$((LeftMargin + EntryTab))
if [ "$MenuStyle" = narrow ]; then
    LettersTab=$((PanelWidth - NavTab - ItemSquare / 2))
else
    LettersTab=$((PanelWidth - RightMargin - ItemSquare / 2))
fi

GlyphScale=$(awk "BEGIN { print $ItemSquare * 0.042 }")

if [ "$MenuStyle" = narrow ]; then
    PanelRadius=$((ItemSquare / 2))
    ItemRadius=0
else
    PanelRadius=0
    ItemRadius=$((ItemSquare / 2))
fi

BarTab=$((PanelWidth * 1/10))
BarWidth=$((PanelWidth - BarTab * 2))
BarLevel=$((PanelHeight + FontSize * 2))
BarHeight=$((FontSize / 5))
BarLimit=50

if [ "$XPercent" = center ]; then
    PanelX=$(((ScreenWidth - PanelWidth) / 2))
else
    PanelX=$((ScreenWidth * $XPercent / 100))
fi

if [ "$YPercent" = center ]; then
    PanelY=$(((ScreenHeight - PanelHeight) / 2))
else
    PanelY=$((ScreenHeight * $YPercent / 100))
fi

xpos() { printf %s $((PanelX + $1)); }

ypos() { printf %s $((PanelY + $1)); }

rgb() {
    if [ "$1" = none ]; then
        printf none
        return
    fi
    printf %s "$1" | awk '     # H S V => (R, G, B)
        END {
            H = ($1 + 0) / 60
            S = ($2 + 0) / 100
            V = ($3 + 0) / 100
            M = V                       # max RGB
            m = M * (1 - S)             # min RGB
            c = M - m                   # range

            if (H >= 5) H = H - 6       # undo wrapping so that H < 0

            if (H < 0)      { R = M; G = m; B = m + (0 - H) * c }
            else if (H < 1) { R = M; G = m + (H - 0) * c; B = m }
            else if (H < 2) { R = m + (2 - H) * c; G = M; B = m }
            else if (H < 3) { R = m; G = M; B = m + (H - 2) * c }
            else if (H < 4) { R = m; G = m + (4 - H) * c; B = M }
            else if (H < 5) { R = m + (H - 4) * c; G = m; B = M }

            R = int(R * 255 + 0.5)
            G = int(G * 255 + 0.5)
            B = int(B * 255 + 0.5)

            print "rgb(" R "," G "," B ")"
        }
    '
}

if [ "$MenuStyle" = wide ]; then
    HeaderBg=$MenuBg
    HeaderOpacity=$MenuOpacity
fi
MenuBg=$(rgb "$MenuBg")
HeaderBg=$(rgb "$HeaderBg")
FocusBg=$(rgb "$FocusBg")
TextFg=$(rgb "$TextFg")
IconFg=$(rgb "$IconFg")
BarBg=$(rgb "$BarBg")
BarFg=$(rgb "$BarFg")

# BACKGROUND PIXELS

open_svg() {
    # $1: width, $2: height, $3 (optional): fill, $4 (optional): opacity
    printf %s "
        <svg xmlns='http://www.w3.org/2000/svg' width='$1' height='$2'
         xmlns:xlink='http://www.w3.org/1999/xlink'>
    " > tmp.svg
    if [ "$3" ]; then
        printf %s "<rect x='0' y='0' width='100%' height='100%' stroke-width='0'
        fill='$3' fill-opacity='${4:-1}' />" >> tmp.svg
    fi
}

convert_svg() {
    # $1: destination
    printf %s\\n "</svg>" >> tmp.svg
    $png_make tmp.svg || stop 'unable to convert SVG to PNG.'
    mv tmp.png "$1" || stop 'could not move tmp.png to destination.'
}

open_svg 1 1 gray
convert_svg "$theme_path/desktop.png" # Cannot be left empty, on the pain of
# screen-rendering bugs!

open_svg 1 1 "$FocusBg" "$FocusOpacity"
convert_svg "$theme_path/item-selected-c.png"

# SCREEN COVERING

[ "$Wallpaper" ] || stop 'no wallpaper specified.'
[ -f "wallpapers/$Wallpaper" ] || stop "cannot find $Wallpaper"

echo 'Preparing wallpaper [may take a few seconds] ... '
$change \
"wallpapers/$Wallpaper" -geometry "${ScreenWidth}x${ScreenHeight}!" paper.png \
|| stop "cannot resize $Wallpaper"

crop() {
    # $1: input file, $2: width, $3: height, $4: x, $5: y, $6: destination
    $change "$1" -crop "$2x$3+$4+$5" "$6"
}

# The full-size wallpaper picture, paper.png, must be split in two parts,
# left.png and right.png. The right part will be be used to cover the text
# side of the actual menu entries.

ScreenL=$(xpos $PanelWidth)
ScreenR=$((ScreenWidth - ScreenL))
crop paper.png "$ScreenL" "$ScreenHeight" 0 0 "$theme_path/left.png"
crop paper.png "$ScreenR" "$ScreenHeight" "$ScreenL" 0 "$theme_path/right.png"

# PANEL HANDLING

add_str() {
    printf %s\\n "$1" >> tmp.svg
}

add_box() {
    # $1: x, $2: y, $3: width, $4: height, $5: fill, $6 (optional): opacity,
    # $7 (optional): corner radius
    add_str "<rect x='$1' y='$2' width='$3' height='$4' fill='$5'
        fill-opacity='${6:-1}' rx='${7:-0}' ry='${7:-0}' stroke-width='0'/>"
}

add_band() {
    # $1: y, $2: height, $3: fill
    add_str "<rect x='0' y='$1' width='100%' height='$2' fill='$3'
        fill-opacity='$4' stroke-width='0' mask='url(#cut)'/>"
}

add_image() {
    add_str "<image x='0' y='0' width='100%' height='$100%' xlink:href='$1'
        mask='url(#cut)'/>"
}

echo 'Preparing menu background [may take a few seconds] ... '
[ "$Sigma" = 0 ] || $smooth "$((Sigma * 3))x${Sigma}" paper.png
crop paper.png "$PanelWidth" "$PanelHeight" "$PanelX" "$PanelY" panel-base.png
rm paper.png

# Menu entries form a middle layer sandwiched between two layers of panel
# rendering. The bottom layer, panel-back.png, is a cutout of the blurred
# wallpaper. The top layer, panel-front.png, is a copy of panel-back.png
# with hollow contours to let the menu-entry graphics show through.

open_svg $PanelWidth $PanelHeight
add_str "<defs> <mask id='cut'>"
add_box 0 0 100% 100% black 1
add_box 0 0 100% 100% white 1 "$PanelRadius"
add_str "</mask> </defs>"
add_image panel-base.png
add_band 0 $HeaderHeight "$HeaderBg" "$HeaderOpacity"
add_band $HeaderHeight $((PanelHeight - HeaderHeight)) "$MenuBg" "$MenuOpacity"
convert_svg panel-back.png
rm panel-base.png

add_text() {
    # $1: x; $2: y; $3: string; $4 (optional): alignment
    add_str "<text x='$1' y='$(($2 + FontSize * 3/10))' text-anchor='${4:-start}'
        font-family='$FontFamily' font-size='$FontSize' xml:space='preserve'
        fill='$TextFg' stroke-width='0'>$3</text>"
}

add_glyph() {
    # $1: filename; $2: x; $3: y; $4: color. Raw glyph area is 24 x 24 pixels,
    # so we must first center the glyph by (-12, -12).
    add_str "<path d='$(cat data/$1)'
         transform='translate($(($2 + ItemSquare/2)), $(($3 + ItemSquare/2)))
         scale($GlyphScale) translate(-12, -12)' stroke-width='0'
         fill-rule='evenodd' fill='$4'/>"
}

contains() {
    printf %s\\n "$1" | grep -E -iq "$2"        # quiet and case insensitive
}

datum() {
    query=$1
    if contains "$query" "$MemoryRegex"; then
        printf %s memory
    elif contains "$query" "$PowerRegex"; then
        printf %s power
    elif contains "$query" "$SnapshotRegex"; then
        printf %s camera
    elif contains "$query" "$SystemRegex"; then
        printf %s cog
    elif contains "$query" '^commodore'; then
        printf %s Commodore
    elif contains "$query" '^guix'; then
        printf %s Guix
    elif contains "$query" 'linux ?mint'; then
        printf %s Mint
    elif contains "$query" '^(macos|osx)'; then
        printf %s Apple
    elif contains "$query" '^pop'; then
        printf %s Pop
    elif contains "$query" '^sparky'; then
        printf %s Sparky
    else
        # Use first word as search key, after cleaning possible suffixes.
        stem=${query%% *}
        stem=${stem%,}
        stem=${stem%OS}
        match=$(ls -1 data/ | grep -E -is "^${stem}$")
        if [ "$match" ]; then
            printf %s "$match"
        else
            printf %s unknown
        fi
    fi
}

open_svg $PanelWidth $PanelHeight
add_str "<defs> <mask id='cut'>"
add_box 0 0 100% 100% white
k=0; while [ $k -lt "$MenuCapacity" ]; do
    add_box \
        $LeftMargin $((TopMargin + k * ItemRoom)) $MenuWidth $ItemSquare \
        black 1 $ItemRadius
    k=$((k + 1))
done
add_str "</mask> </defs>"
add_image panel-back.png
add_text $TitleTab $TopLevel "$Title"
add_glyph top $NavTab $TopNavLevel $TextFg
add_text $LettersTab $TopLevel "$CommandMsg" end
add_glyph bottom $NavTab $BottomNavLevel $TextFg
add_text $LettersTab $BottomLevel "$EnterMsg" end
convert_svg panel-front.png

mv panel-back.png panel-front.png "$theme_path"

# PROGRESS BAR

make_bar() {
    # $1: color; $2: filename
    open_svg 1 $BarLimit
    add_box 0 0 1 $BarHeight $1
    convert_svg "$theme_path/$2"
}

make_bar $BarBg bar-default-c.png
make_bar $BarFg bar-highlighted-c.png

# THEME FILE

{
cat << DOC
title-text: ""

desktop-image: "desktop.png"

terminal-left: "10%"
terminal-top: "10%"
terminal-width: "80%"
terminal-height: "80%"

+ image {
    left = $(xpos 0)
    top = $(ypos 0)
    file = "panel-front.png"
}

+ image {
    left = $ScreenL
    top = 0
    width = $ScreenR
    height = 100%
    file = "right.png"
}

+ boot_menu {
    left = $(xpos $LeftMargin)
    top = $(ypos $TopMargin)
    width = $MenuWidth
    height = $MenuHeight
    item_color = gray
    selected_item_color = gray
    icon_width = $MenuWidth
    icon_height = $ItemSquare
    item_icon_space = 0
    item_padding = 0
    item_height = $ItemSquare
    item_spacing = $ItemSpacing
    selected_item_pixmap_style = "item-selected-*.png"
}

+ progress_bar {
    id = "__timeout__"
    left = $(xpos $BarTab)
    top = $(ypos $BarLevel)
    width = $BarWidth
    bar_style = "bar-default-*.png"
    highlight_style = "bar-highlighted-*.png"
}

+ image {
    left = $(xpos 0)
    top = $(ypos 0)
    file = "panel-back.png"
}

+ image {
    left = 0
    top = 0
    width = $ScreenL
    height = 100%
    file = "left.png"
}

DOC
} > "$theme_file"

# CONFIGURATION GENERATION

sed -i '/GRUB_BACKGROUND/s,^.*$,#GRUB_BACKGROUND="wallpaper",' "$grub_control"
if grep -q 'GRUB_THEME' "$grub_control"; then
    sed -i "/GRUB_THEME/s,^.*$,GRUB_THEME=$theme_file," "$grub_control"
else
    printf %s\\n "GRUB_THEME=$theme_file" >> "$grub_control"
fi

grub-mkconfig -o "$grub_config_file" || stop 'could not configure GRUB.'

# MENU ENTRIES REPLACEMENT

rm custom.cfg scan.txt 2>/dev/null

< "$grub_config_file" awk '
BEGIN {
    DQ = "\042"
    SQ = "\047"
    EntryRegex = "^[[:blank:]]*(menuentry|submenu) [" DQ SQ "]"
    EscapedQuote = "\\\\" DQ
    Space = " "
}
{
    line = $0
    if (match(line, EntryRegex) > 0) {
        first_quote_pos = RLENGTH
        quote = substr(line, first_quote_pos, 1)
        cmd_head = substr(line, 1, first_quote_pos - 2)
        remainder = substr(line, first_quote_pos + 1)
        gsub(EscapedQuote, "", remainder) # simplify search for title end
        if (match(remainder, quote Space) > 0) {
            second_quote_pos = RSTART
            title = substr(remainder, 1, second_quote_pos - 1)
            gsub("<", "\\&lt;", title) # sanitize title for SVG handling
            cmd_tail = substr(remainder, second_quote_pos + 2)
            class = "--class menuitem" ++num
            line = cmd_head Space quote title quote Space class Space cmd_tail
            category = match(cmd_head, "menuentry") > 0 ? "ENTRY" : "SUBMENU"
            print category ":" title > "scan.txt"
        }
    }
    print(line) > "custom.cfg"
}
' || stop 'configuration scan failure'

[ -f scan.txt ] || stop 'no captions generated.'

mv custom.cfg "$grub_config_file" || stop "cannot update $grub_config_file"

install_item() {
    # $1: index; $2: category; $3: caption
    open_svg $MenuWidth $ItemSquare
    if [ "$2" = SUBMENU ]; then
        add_glyph more $Tab 0 $IconFg
    else
        add_glyph $(datum "$3") $Tab 0 $IconFg
    fi
    add_text $EntryTab $((ItemSquare / 2)) "$3"
    convert_svg "$icons_path/menuitem${1}.png"
}

printf %s 'Checking menu entries [may take a few seconds] ... '
index=0; while read entry; do
    index=$((index + 1))
    category=${entry%%:*}
    caption=${entry#*:}
    install_item $index "$category" "$caption"
done < scan.txt
rm scan.txt
rm tmp.svg

cat << DOC


-----------------------------
Theme installed successfully!
-----------------------------
You can now reboot your computer to see what the theme looks like.
Alternatively, if instead of rebooting you just want to preview
the results, you can use any image viewer to open:

/usr/share/grub/themes/evodevo/panel-back.png
/usr/share/grub/themes/evodevo/panel-front.png

and

/usr/share/grub/themes/evodevo/icons/*png

DOC

