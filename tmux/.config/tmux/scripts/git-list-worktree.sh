#!/bin/zsh

MAIN_REPO="${GIT_MAIN_REPO:-$HOME/repos/main}"
WORKTREE_ROOT="${GIT_WORKTREE_ROOT:-$HOME/repos/worktrees}"

function git-list-worktree() {
  pushd "$MAIN_REPO" >/dev/null 2>&1 || return 1

  # Get worktree list with branch and path
  local worktree_info=$(git worktree list --porcelain | awk '
    /^worktree / { path=$2 }
    /^branch / {
      branch=$2
      sub(/refs\/heads\//, "", branch)
      if (branch != "main") print branch "\t" path
    }
  ')

  if [ -z "$worktree_info" ]; then
    echo "No worktrees found (excluding main)"
    popd >/dev/null 2>&1
    return 1
  fi

  # Use fzf to select a worktree
  local selected=$(echo "$worktree_info" | fzf \
    --prompt="Select worktree > " \
    --header="Press ENTER to copy branch name, ESC to cancel" \
    --preview="echo {2} && echo && git -C {2} status -sb 2>/dev/null || echo 'Not available'" \
    --preview-window=right:50% \
    --delimiter="\t" \
    --with-nth=1)

  popd >/dev/null 2>&1

  if [ -z "$selected" ]; then
    return 0
  fi

  local branch_name=$(echo "$selected" | cut -f1)

  echo -n "$branch_name" | pbcopy
  tmux display-message "Copied: $branch_name"
}

git-list-worktree
