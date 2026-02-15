#!/bin/bash

# Configuration variables (defaults used when unset or empty)
export WINEPREFIX="${WINEPREFIX:-/config/.wine}"
export WINEDEBUG="${WINEDEBUG:--all}"
wine_executable="${wine_executable:-wine}"
mt5file="${WINEPREFIX}/drive_c/Program Files/MetaTrader 5/terminal64.exe"
metatrader_version="5.0.36"
mt5server_port="8001"
MT5_CMD_OPTIONS="${MT5_CMD_OPTIONS:-}"
mono_url="${mono_url:-https://dl.winehq.org/wine/wine-mono/10.3.0/wine-mono-10.3.0-x86.msi}"
python_url="${python_url:-https://www.python.org/ftp/python/3.9.13/python-3.9.13.exe}"
wine_python="${wine_python:-C:\\Program Files (x86)\\Python39-32\\python.exe}"
mt5setup_url="${mt5setup_url:-https://download.mql5.com/cdn/web/metaquotes.software.corp/mt5/mt5setup.exe}"
wine_reg='C:\windows\system32\reg.exe'

# Strip trailing carriage return from vars (fixes CRLF line endings)
wine_executable="${wine_executable%$'\r'}"
mt5setup_url="${mt5setup_url%$'\r'}"
python_url="${python_url%$'\r'}"
mono_url="${mono_url%$'\r'}"
wine_python="${wine_python%$'\r'}"

# Fail fast if critical variables are empty
if [ -z "$wine_executable" ] || [ -z "$mt5setup_url" ] || [ -z "$python_url" ]; then
    echo "Error: wine_executable, mt5setup_url or python_url is empty. Check script encoding (use LF, not CRLF)."
    exit 1
fi

# Function to display a graphical message
show_message() {
    echo $1
}

# Function to check if a dependency is installed
check_dependency() {
    if ! command -v $1 &> /dev/null; then
        echo "$1 is not installed. Please install it to continue."
        exit 1
    fi
}

# Function to check if a Python package is installed
is_python_package_installed() {
    $wine_executable "$wine_python" -c "import pkg_resources; exit(not pkg_resources.require('$1'))" 2>/dev/null
    return $?
}

# Function to check if a Python package is installed in Wine
is_wine_python_package_installed() {
    $wine_executable "$wine_python" -c "import pkg_resources; exit(not pkg_resources.require('$1'))" 2>/dev/null
    return $?
}

# Check for necessary dependencies
check_dependency "curl"
check_dependency "$wine_executable"

# Install Mono if not present
if [ ! -e "${WINEPREFIX}/drive_c/windows/mono" ]; then
    show_message "[1/7] Downloading and installing Mono..."
    curl -o "${WINEPREFIX}/drive_c/mono.msi" "$mono_url"
    WINEDLLOVERRIDES=mscoree=d $wine_executable msiexec /i "${WINEPREFIX}/drive_c/mono.msi" /qn
    rm -f "${WINEPREFIX}/drive_c/mono.msi"
    show_message "[1/7] Mono installed."
else
    show_message "[1/7] Mono is already installed."
fi

# Check if MetaTrader 5 is already installed
if [ -e "$mt5file" ]; then
    show_message "[2/7] File $mt5file already exists."
else
    show_message "[2/7] File $mt5file is not installed. Installing..."

    # Set Windows 10 mode in Wine and download and install MT5
    $wine_executable "$wine_reg" add "HKEY_CURRENT_USER\\Software\\Wine" /v Version /t REG_SZ /d "win10" /f
    show_message "[3/7] Downloading MT5 installer..."
    curl -L -o "${WINEPREFIX}/drive_c/mt5setup.exe" "$mt5setup_url"
    show_message "[3/7] Installing MetaTrader 5..."
    $wine_executable "${WINEPREFIX}/drive_c/mt5setup.exe" /auto &
    wait
    rm -f "${WINEPREFIX}/drive_c/mt5setup.exe"
fi

# Recheck if MetaTrader 5 is installed
if [ -e "$mt5file" ]; then
    show_message "[4/7] File $mt5file is installed. Running MT5..."
    $wine_executable "$mt5file" $MT5_CMD_OPTIONS &
else
    show_message "[4/7] File $mt5file is not installed. MT5 cannot be run."
fi


# Install Python in Wine if not present
if ! $wine_executable "$wine_python" --version 2>/dev/null; then
    show_message "[5/7] Installing Python in Wine..."
    curl -L -o /tmp/python-installer.exe "$python_url"
    $wine_executable /tmp/python-installer.exe /quiet InstallAllUsers=1 PrependPath=1
    rm -f /tmp/python-installer.exe
    show_message "[5/7] Python installed in Wine."
else
    show_message "[5/7] Python is already installed in Wine."
fi

# Upgrade pip and install required packages
show_message "[6/7] Installing Python libraries"
$wine_executable "$wine_python" -m pip install --upgrade --no-cache-dir pip
# Install MetaTrader5 library in Windows if not installed
show_message "[6/7] Installing MetaTrader5 library in Windows"
if ! is_wine_python_package_installed "MetaTrader5==$metatrader_version"; then
    $wine_executable "$wine_python" -m pip install --no-cache-dir MetaTrader5==$metatrader_version
fi
# Install mt5linux library in Windows if not installed
show_message "[6/7] Checking and installing mt5linux library in Windows if necessary"
if ! is_wine_python_package_installed "mt5linux"; then
    $wine_executable "$wine_python" -m pip install --no-cache-dir "mt5linux>=0.1.9"
fi

# Install python-dateutil if needed (datetime is built-in, but dateutil adds features)
if ! is_wine_python_package_installed "python-dateutil"; then
    show_message "[6/7] Installing python-dateutil library in Windows"
    $wine_executable "$wine_python" -m pip install --no-cache-dir python-dateutil
fi

# Install mt5linux library in Linux if not installed
show_message "[6/7] Checking and installing mt5linux library in Linux if necessary"
if ! is_python_package_installed "mt5linux"; then
    pip install --break-system-packages --no-cache-dir --no-deps mt5linux && \
    pip install --break-system-packages --no-cache-dir rpyc plumbum "numpy<2"
fi

# Install pyxdg library in Linux if not installed
show_message "[6/7] Checking and installing pyxdg library in Linux if necessary"
if ! is_python_package_installed "pyxdg"; then
    pip install --break-system-packages --no-cache-dir pyxdg
fi

# Start the MT5 server on Linux
show_message "[7/7] Starting the mt5linux server..."
$wine_executable "$wine_python" -m mt5linux --host 0.0.0.0 -p $mt5server_port

# Give the server some time to start
sleep 5

# Check if the server is running
if ss -tuln | grep ":$mt5server_port" > /dev/null; then
    show_message "[7/7] The mt5linux server is running on port $mt5server_port."
else
    show_message "[7/7] Failed to start the mt5linux server on port $mt5server_port."
fi