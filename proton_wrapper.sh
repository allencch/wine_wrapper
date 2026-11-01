#!/bin/bash

# Re-write with Gemini and ChatGPT

# Configuration
# Expects _BASE_PATH to be set by the caller (e.g., GE-Proton9-11 folder)
_PROTON_BIN="${_BASE_PATH}/proton"
_PROTON_DIR="${_BASE_PATH}/files"

# Required by Proton to run outside of Steam
export STEAM_COMPAT_CLIENT_INSTALL_PATH="/tmp"
export STEAM_COMPAT_DATA_PATH="" # Will be set by -p argument

# Internal variables
_WINEDLLOVERRIDES=""
CALL_WINETRICKS=false
CALL_SHUTDOWN=false
CALL_KILL=false
CALL_WINEBOOT=false
CALL_WINE=false
ARGS=()

if [ "$#" -le "1" ] ; then
    echo -e "Usage: proton_wrapper.sh -p <wineprefix> [options] arguments ..."
    exit 1
fi

# Parse Arguments
while [ "$1" != "" ]; do
    case $1 in
        -p | --prefix)
            shift
            _WINEPREFIX="$(realpath "$1")"
            export STEAM_COMPAT_DATA_PATH="$_WINEPREFIX"
            ;;
        --shutdown)
            CALL_SHUTDOWN=true
            ;;
        --kill)
            CALL_KILL=true
            ;;
        --wineboot)
            CALL_WINEBOOT=true
            ;;
        --winetricks)
            CALL_WINETRICKS=true
            ;;
        --wine)
            CALL_WINE=true
            ;;
        --dll)
            shift
            # Append DLL overrides, ensuring they are comma-separated
            if [ -z "$_WINEDLLOVERRIDES" ]; then
                _WINEDLLOVERRIDES="$1"
            else
                _WINEDLLOVERRIDES="$_WINEDLLOVERRIDES;$1"
            fi
            ;;
        *)
            ARGS+=("$1")
            ;;
    esac
    shift
done

# Ensure prefix directory exists
if [ ! -d "$_WINEPREFIX" ]; then
    mkdir -p "$_WINEPREFIX"
fi

# Environment Setup Function
function setup_env() {
    # Proton expects the actual wine prefix to be in a subfolder named 'pfx'
    export WINEPREFIX="$_WINEPREFIX/pfx"

    # Standard paths for GE-Proton
    export PATH="$_PROTON_DIR/bin:$PATH"
    export LD_LIBRARY_PATH="$_PROTON_DIR/lib:$_PROTON_DIR/lib64:$LD_LIBRARY_PATH"

    # Apply DLL Overrides if any
    if [ -n "$_WINEDLLOVERRIDES" ]; then
        export WINEDLLOVERRIDES="$_WINEDLLOVERRIDES"
    fi

    # Useful for debugging
    # export WINEDEBUG=-all,err+all
}

# Logic Execution
if [ "$CALL_KILL" = true ]; then
    setup_env
    wineserver -k
elif [ "$CALL_SHUTDOWN" = true ]; then
    setup_env
    wineserver -s
elif [ "$CALL_WINETRICKS" = true ]; then
    setup_env
    winetricks "${ARGS[@]}"
elif [ "$CALL_WINEBOOT" = true ]; then
    setup_env
    wineboot -u
elif [ "$CALL_WINE" = true ] || [ ${#ARGS[@]} -gt 0 ]; then
    setup_env
    # UMU Style: Use the 'runinprefix' verb to bypass the need for 'steam.exe'
    # This allows passing arguments directly to the .exe
    "$_PROTON_BIN" run "${ARGS[@]}"
fi
