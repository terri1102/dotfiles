#!/bin/bash

# Oh My Zsh
install_oh_my_zsh() {
    echo "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
}

# Starship
install_starship() {
    echo "Installing Starship..."
    curl -sS https://starship.rs/install.sh | sh
}

# ZSH plugins
install_plugins() {
    echo "Installing ZSH plugins..."
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
}

# Copy Starship config
create_starship_config() {
    echo "Creating Starship configuration..."
    mkdir -p ~/.config
    cp -f dot_starship ~/.config/starship.toml || {
        echo "Copy failed" >&2
        return 1
    }
}

# Copy zshrc
create_zshrc() {
    echo "Copying .zshrc configuration..."
    cp -f dot_zshrc ./zshrc || {
        echo "Copy failed" >&2
        return 1
    }
    source ./zshrc
}

# Set zsh as default shell
change_default_shell() {
    echo "Changing default shell to ZSH..."
    chsh -s $(which zsh)
}

# Main function
main() {
    install_packages
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
