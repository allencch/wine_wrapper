# Wine wrapper

To create a prefix,

```
export base="$HOME/mywines/prefix/games"
/path/to/wine_wrapper.sh -p "$base" explorer
```

NOTE: The following commands assuming you have set your prefix paths to `$base` variable.

To install libraries through winetricks,

```
/path/to/wine_wrapper.sh -p "$base" --winetricks -q
```

To shutdown,

```
/path/to/wine_wrapper.sh -p "$base" --shutdown
```

To kill all processes of a prefix,

```
/path/to/wine_wrapper.sh -p "$base" --kill
```

To run with different language,

```
LANG=zh_CN.UTF-8 /path/to/wine_wrapper.sh -p "$base" explorer
```

To run with `bumblebee`,

```
optirun /path/to/wine_wrapper.sh -p "$base" explorer
```

To run without network,

```
firejail --noprofile --net=none /path/to/wine_wrapper.sh -p "$base" explorer
```


## Custom built wine

Let's say we downloaded different version of Wine through PlayOnLinux, or custom built Wine,

```
/path/to/wine_wrapper.sh -p "$base" --winepath ~/.PlayOnLinux/wine/linux-x64/4.11 my_games.exe
```

Let's say the downloaded wine is 32-bit,

```
/path/to/wine_wrapper.sh --win32 -p "$base" --winepath ~/.PlayOnLinux/wine/linux-x86/4.11 my_games.exe
```

## Build custom Wine and support both 64-bit and 32-bit

Once you download the source code of older version of Wine, such as wine-4.2,

```
tar xJf wine-4.2.tar.xz
patch -u -p1 < ../swshader_ivb.patch # apply patch
```

Then we can build the Wine that supports both architecture, assuming we are in the working directory `$HOME/mywines/builds/wine-4.2`.

```
#!/bin/bash

WINENAME="wine-4.2-sw-blend"
srcdir="$(pwd)"
mkdir build-64 build-32

cd "$srcdir/build-64"
../configure --prefix=$HOME/mywines/$WINENAME \
  --libdir=$HOME/mywines/$WINENAME/lib \
  --enable-win64 --with-x
make -j4
cd "$srcdir/build-32"
PKG_CONFIG_PATH=/usr/lib32/pkgconfig ../configure \
  --prefix=$HOME/mywines/$WINENAME \
  --libdir=$HOME/mywines/$WINENAME/lib32 \
  --with-wine64=$srcdir/build-64 \
  --with-x
make -j4

cd "$srcdir/build-64"
make install
cd "$srcdir/build-32"
make install
```

# Proton wrapper

We can download Proton through Steam.
Once downloaded, `proton_wrapper.sh` will locate the Proton and run like `wine_wrapper.sh`.
`proton_wrapper.sh` has similar arguments as `wine_wrapper.sh`.
For example,

```
/path/to/proton_wrapper.sh -p "$base" explorer
/path/to/proton_wrapper.sh -p "$base" --winetricks -q
```

To use different version of Proton (default is 4.11),

```
/path/to/proton_wrapper.sh --version 4.2 -p "$base" explorer
```

Note that, Proton creates slightly different file structure as `$base/pfx/drive_c`, while the usual Wine creates as `$base/drive_c`.

## Proton version 5.0 and above

`steam.exe` in Proton 5.0 and above doesn't work with arguments, like `notepad test.txt`.
We can either solve it by invoking a `.bat` file to wrap the argument, or edit the `proton` script.

To use `.bat` file, eg,

```
; mynotepad.bat
notepad test.txt
```

Then run with `mynotepad.bat`

To edit the `proton` script, look for line involves

```
self.run_proc([g_proton.wine64_bin, "steam"] + sys.argv[2:] + self.cmdlineappend)
```

Remove `steam` and save it. So that proton will run directly using the `wine.exe` instead through `steam.exe`.

In order to make the original proton script continue to work, the edited file is recommended to save as `proton_lite`.


# Create shortcut

To create shortcut like PlayOnLinux, for example create a `~/shortcuts/minesweeper.sh` with the following content,

```
#!/bin/bash

export base="$HOME/mywines/prefix/games"
cd "$base/drive_c/My Game"
~/wine_wrapper.sh -p "$base" minesweeper.exe
```
