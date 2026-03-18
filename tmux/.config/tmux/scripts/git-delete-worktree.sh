#!/bin/zsh

MAIN_REPO="${GIT_MAIN_REPO:-$HOME/repos/main}"
WORKTREE_ROOT="${GIT_WORKTREE_ROOT:-$HOME/repos/worktrees}"
CODE_WORKSPACES_DIR=~/Workspace/code-workspaces/worktree

function git-delete-worktree() {
  local branch_name="$1"
  local git_worktree_path="$WORKTREE_ROOT/$branch_name"
  local code_workspace_file="$CODE_WORKSPACES_DIR/$branch_name.code-workspace"

  # Remove the worktree branch (Should delete the worktree directory as well)
  pushd $MAIN_REPO >/dev/null 2>&1
  git worktree remove $branch_name --force
  popd

  # Remove the code workspace file
  if [ -f "$code_workspace_file" ]; then
    rm "$code_workspace_file"
    echo "Code workspace file deleted"
  fi

  # Remove the tmux session
  if tmux has-session -t "$branch_name" 2>/dev/null; then
    tmux kill-session -t "$branch_name"
    echo "Tmux session deleted"
  fi

  if [ -d "$git_worktree_path" ]; then
    rm -rf "$git_worktree_path"
    echo "Worktree directory deleted"
  fi
}

local branch_name="$1"
[ -n "$branch_name" ] || exit 1

tmux set -g @wt_status "⟳ wt"
tmux refresh-client -S

local logfile="/tmp/wt-delete-${branch_name//\//-}.log"
exec > "$logfile" 2>&1

echo "Deleting worktree: $branch_name..."
git-delete-worktree $branch_name || {
  tmux set -g @wt_status ""
  tmux refresh-client -S
  tmux display-popup -E -w 80% -h 60% "less '$logfile'; rm -f '$logfile'"
  exit 1
}
tmux set -g @wt_status ""
tmux refresh-client -S
tmux display-popup -E -w 80% -h 60% "less '$logfile'; rm -f '$logfile'"
