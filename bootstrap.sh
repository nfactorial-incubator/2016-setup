#!/usr/bin/env bash

# Prepare a laptop for N17R programming classes.

# Ask for the administrator password upfront.
sudo -v

# Keep-alive: update existing `sudo` time stamp until the script has finished.
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Install Xcode command line tools.
xcode-select --install
read -p "Press [Enter] key when Xcode command line tools are installed..."

# Install Homebrew, if we don't have it.
if test ! $(which brew); then
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

# Make sure we’re using the latest Homebrew.
brew update

# Upgrade any already-installed formulae.
brew upgrade --all

# Install git tools.
brew install git
brew install git-extras

# Install zsh.
brew install zsh
command -v zsh | sudo tee -a /etc/shells
chsh -s /usr/local/bin/zsh

# Use the Monokai theme by default in Terminal.app
osascript <<EOD
tell application "Terminal"
  local allOpenedWindows
  local initialOpenedWindows
  local windowID
  set themeName to "Monokai"
  (* Store the IDs of all the open terminal windows. *)
  set initialOpenedWindows to id of every window
  (* Open the custom theme so that it gets added to the list
     of available terminal themes (note: this will open two
     additional terminal windows). *)
  do shell script "open '$HOME/dotfiles/" & themeName & ".terminal'"
  (* Wait a little bit to ensure that the custom theme is added. *)
  delay 1
  (* Set the custom theme as the default terminal theme. *)
  set default settings to settings set themeName
  (* Get the IDs of all the currently opened terminal windows. *)
  set allOpenedWindows to id of every window
  repeat with windowID in allOpenedWindows
    (* Close the additional windows that were opened in order
       to add the custom theme to the list of terminal themes. *)
    if initialOpenedWindows does not contain windowID then
      close (every window whose id is windowID)
    (* Change the theme for the initial opened terminal windows
       to remove the need to close them in order for the custom
       theme to be applied. *)
    else
      set current settings of tabs of (every window whose id is windowID) to settings set themeName
    end if
  end repeat
end tell
EOD

# Install Node.js, Python, and rbenv.
brew install node
brew install python
brew install rbenv ruby-build
rbenv install 2.3.0
rbenv global 2.3.0
rbenv rehash

# Install essential binaries.
brew install trash
brew install fzf

# Install iOS and OSX development tools.
brew install thoughtbot/formulae/liftoff
brew install keith/formulae/cocoapods
brew install carthage
brew install jondot/tap/blade
gem install xcode-install
gem install fastlane

# Install cask.
brew install caskroom/cask/brew-cask

apps=(
 atom
 qlcolorcode
 qlmarkdown
 qlstephen
 slack
 sourcetree
)

# Install apps with cask.
# Set the destination as /Applications instead of ~/Applications.
brew cask install --appdir="/Applications" ${apps[@]}

# Remove outdated versions from the cellar.
brew cask cleanup
brew cleanup

# Configure git.
shopt -s nocasematch

unset name
while [[ ! $name =~ ^[a-zа-я\-]{2,}([[:space:]]+[a-zа-я\-]{2,})+$ ]]; do
    read -p 'Your first and last name: ' name
done

unset email
while [[ ! $email =~ ^[a-z0-9\._%\+\-]+@[a-z0-9\.\-]+\.[a-z]{2,4}$ ]]; do
    read -p 'Your email (the one used for your GitHub account): ' email
done

shopt -u nocasematch

git config --global user.name "$name"
git config --global user.email $email

# Generate a new public key.
ssh-keygen -t rsa
echo "Add this public key to Github \n"
echo "https://github.com/account/ssh \n"
read -p "Press [Enter] key after this..."

echo "Awesome! Your laptop is almost ready. Follow the rest of the guide to configure your dotfiles."
