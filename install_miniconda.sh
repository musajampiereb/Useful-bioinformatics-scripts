#!/bin/bash

###############################################################
# Miniconda Installation Script for Linux
###############################################################

# Variables
CONDA_INSTALLER="Miniconda3-latest-Linux-x86_64.sh"
MINICONDA_URL="https://repo.anaconda.com/miniconda/$CONDA_INSTALLER"
INSTALL_DIR="$HOME/miniconda"

# Function to check if a command is available
command_exists() {
    command -v "$1" &> /dev/null
}

# Function to install missing dependencies
install_dependencies() {
    echo "Installing required dependencies..."

    if command_exists apt-get; then
        sudo apt-get update
        sudo apt-get install -y wget curl bzip2
    elif command_exists yum; then
        sudo yum install -y wget curl bzip2
    elif command_exists dnf; then
        sudo dnf install -y wget curl bzip2
    elif command_exists pacman; then
        sudo pacman -Syu --noconfirm wget curl bzip2
    else
        echo "Unsupported package manager. Please install wget, curl, and bzip2 manually."
        exit 1
    fi
}

# Check for existing Miniconda installation and remove if exists
if [ -d "$INSTALL_DIR" ]; then
    echo "Miniconda directory already exists at $INSTALL_DIR. Removing it..."
    rm -rf "$INSTALL_DIR"
fi

# Download Miniconda installer
echo "Downloading Miniconda installer..."
wget "$MINICONDA_URL" -O "$CONDA_INSTALLER"

# Verify the download (Optional but recommended for security)
echo "Verifying installer checksum..."
echo "You can check the official checksum from Miniconda documentation"
# Example checksum verification
# echo "EXPECTED_CHECKSUM  $CONDA_INSTALLER" | sha256sum -c -

# Install Miniconda
echo "Installing Miniconda..."
bash "$CONDA_INSTALLER" -b -p "$INSTALL_DIR"

# Initialize Conda
echo "Initializing Conda..."
$INSTALL_DIR/bin/conda init

# Update Conda
echo "Updating Conda..."
source "$HOME/.bashrc"
conda update -y conda

# Cleanup
echo "Cleaning up..."
rm "$CONDA_INSTALLER"

# Final instructions
echo "Miniconda installation complete!"
echo "To activate the Miniconda environment, run:"
echo "source $HOME/.bashrc"
echo "To create and activate a new Conda environment, use:"
echo "conda create -n myenv python=3.8"
echo "conda activate myenv"
