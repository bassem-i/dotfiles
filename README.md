# dotfiles

This repo contains the dot configuration files for Git & Zsh.

The goal is to be able to share the files across multiple devices and unify my
development experience.

Required steps:

1. Clone the repo into `~/Workspace`.
2. Make sure zsh is your default shell.
3. Install homebrew.
4. Run `init.sh`.

## How to link the dotfiles

The configuration setup depends on a package called
[GNU Stow](https://www.gnu.org/software/stow/) to setup symlinks.

Use this command to create the symlinks:

```
stow -t HOME_DIRECTORY -S PACKAGE_NAME
```
