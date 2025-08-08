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
    --header="Press ENTER to switch, ESC to cancel" \
    --preview="echo {2} && echo && git -C {2} status -sb 2>/dev/null || echo 'Not available'" \
    --preview-window=right:50% \
    --delimiter="\t" \
    --with-nth=1)

  popd >/dev/null 2>&1

  if [ -z "$selected" ]; then
    return 0
  fi

  local branch_name=$(echo "$selected" | cut -f1)

  # Switch to or create tmux session for the selected worktree
  if tmux has-session -t "$branch_name" 2>/dev/null; then
    tmux switch-client -t "$branch_name"
  else
    local worktree_path="$WORKTREE_ROOT/$branch_name"
    if [ -d "$worktree_path" ]; then
      tmux new-session -d -s "$branch_name" -c "$worktree_path"
      tmux switch-client -t "$branch_name"
    else
      echo "Worktree directory not found: $worktree_path"
      return 1
    fi
  fi
}

git-list-worktree
