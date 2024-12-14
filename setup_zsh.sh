#!/bin/bash

# set -e  # Exit on error
set -x # Debug mode

# Check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Oh My Zsh
install_oh_my_zsh() {
    if [ -d "$HOME/.oh-my-zsh" ]; then
        echo "Oh My Zsh is already installed. Skipping..."
    else
        echo "Installing Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi
}

# Starship
install_starship() {
    if command_exists starship; then
        echo "Starship is already installed. Skipping..."
    else
        echo "Installing Starship..."
        mkdir -p ~/.local/bin
        curl -sS https://starship.rs/install.sh | sh -s -- -y -b ~/.local/bin
    fi
}

# ZSH plugins
install_plugins() {
    echo "Installing ZSH plugins..."
    if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
        git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    else
        echo "zsh-autosuggestions is already installed. Skipping..."
    fi

    if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]; then
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    else
        echo "zsh-syntax-highlighting is already installed. Skipping..."
    fi

    if command_exists autojump; then
        echo "autojump is already installed. Skipping..."
    else
        git clone https://github.com/wting/autojump.git && cd autojump && ./install.py && cd ..
        rm -rf autojump
    fi
}

# Copy Starship config
create_starship_config() {
    echo "Creating Starship configuration..."
    mkdir -p ~/.config
    if [ -f "~/.config/starship.toml" ]; then
        echo "Starship configuration already exists. Skipping..."
    else
        cp -f dot_starship ~/.config/starship.toml || {
            echo "Copy failed" >&2
            return 1
        }
    fi
}

# Copy zshrc
create_zshrc() {
    echo "Copying .zshrc configuration..."
    cp -f dot_zshrc ~/.zshrc || {
        echo "Copy failed" >&2
        return 1
    }
}

change_default_shell() {
    echo "Changing default shell..."
    read -r -d '' ZSH_CONFIG << 'EOF'
export SHELL=$(which zsh)
exec $(which zsh) -l
EOF

    if [ -f "$HOME/.bash_profile" ]; then
        echo "Writing to .bash_profile..."
        echo "$ZSH_CONFIG" >> "$HOME/.bash_profile" || {
            echo "Error: Failed to write to .bash_profile" >&2
            return 1
        }
    elif [ -f "$HOME/.profile" ]; then
        echo "Writing to .profile..."
        echo "$ZSH_CONFIG" >> "$HOME/.profile" || {
            echo "Error: Failed to write to .profile" >&2
            return 1
        }
    else
        echo "Creating .profile..."
        echo "$ZSH_CONFIG" > "$HOME/.profile" || {
            echo "Error: Failed to create .profile" >&2
            return 1
        }
    fi
    echo "Shell change completed successfully"
}

# Main function
main() {
    install_oh_my_zsh
    install_starship
    install_plugins
    create_starship_config
    create_zshrc
    change_default_shell
    
    echo "Installation completed! Please log out and log back in for changes to take effect."
    echo "After logging back in, your new ZSH configuration will be ready."
}

# 스크립트 실행
main
