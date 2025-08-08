
export LANG="en_US.UTF-8"

## ---------------------------------------------------------------------------------------
## Device specific config.

if [ -d "~/Workspace/dotfiles/devices/$(hostname)" ]; then
  source ~/Workspace/dotfiles/devices/$(hostname)/.zshenv
fi
