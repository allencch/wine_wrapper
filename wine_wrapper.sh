#!/bin/bash
_WINEARCH=win64
_WINEPREFIX="$HOME/.wine"
_WINEDLLOVERRIDES="winemenubuilder.exe=d;mscoree;mshtml"
_WINEDEBUG=fixme-all
_WINEPATH=""
_WINEBIN=wine
CALL_WINETRICKS=false
CALL_CONSOLE=false
CALL_SHUTDOWN=false
CALL_REBOOT=false
CALL_KILL=false
CALL_WINEBOOT=false
ARGS=()

if [ "$#" -le "1" ] ; then
    echo -e "Usage: wine_wrapper.sh -p <wineprefix> arguments ..."
    exit
fi

while [ "$1" != "" ]; do
    case $1 in
        -p | --prefix)
            shift
            _WINEPREFIX="$1"
            ;;
        --winetricks)
            CALL_WINETRICKS=true
            ;;
        --win32)
            _WINEARCH=win32
            ;;
        --console)
            CALL_CONSOLE=true
            ;;
        --shutdown)
            CALL_SHUTDOWN=true
            ;;
        --reboot)
            CALL_REBOOT=true
            ;;
        --kill)
            CALL_KILL=true
            ;;
        --winepath)
            shift
            _WINEPATH="$1"
            ;;
        --wine)
            shift
            _WINEBIN="$1"
            ;;
        --wineboot)
            CALL_WINEBOOT=true
            ;;
        *)
            ARGS+=("$1")
    esac
    shift
done

export WINEARCH="$_WINEARCH"
export WINEDLLOVERRIDES="$_WINEDLLOVERRIDES"
export WINEPREFIX="$_WINEPREFIX"
export WINEDEBUG="$_WINEDEBUG"

if [ -n "$_WINEPATH" ]; then
    export PATH="$_WINEPATH/bin:$PATH"

    # https://gist.github.com/shmerl/a2867c5a675ed1795f03326b32b47fe7
    # May need to add arch suffix
    export LD_LIBRARY_PATH="$_WINEPATH/lib:$_WINEPATH/lib64:$_WINEPATH/lib32:$LD_LIBRARY_PATH"
fi

if [ "$CALL_WINETRICKS" = true ]; then
    winetricks "${ARGS[@]}"
elif [ "$CALL_CONSOLE" = true ]; then
    wineconsole
elif [ "$CALL_SHUTDOWN" = true ]; then
    wineboot -s
elif [ "$CALL_REBOOT" = true ]; then
    wineboot -r
elif [ "$CALL_KILL" = true ]; then
    wineserver -k
elif [ "$CALL_WINEBOOT" = true ]; then
    wineboot "${ARGS[@]}"
else
    $_WINEBIN "${ARGS[@]}"
fi
