#!/bin/zsh

MAIN_REPO="${GIT_MAIN_REPO:-$HOME/repos/main}"
WORKTREE_ROOT="${GIT_WORKTREE_ROOT:-$HOME/repos/worktrees}"
CODE_WORKSPACES_DIR=~/Workspace/code-workspaces/Worktree

# Create new git worktree if it doesn't exist.
function create_git_worktree() {
  local branch_name="$1"
  local worktree_dir=$WORKTREE_ROOT/$branch_name

  if [ ! -d $worktree_dir ]; then
    echo "Creating git worktree..."

    # Create a folder for the worktree
    mkdir -p $worktree_dir

    # Create the git worktree
    pushd $MAIN_REPO
    git pull --no-progress origin main

    if git show-ref --verify --quiet "refs/heads/$branch_name"; then
      git worktree add -q -f $worktree_dir $branch_name
    else
      git worktree add -q -f $worktree_dir -b $branch_name
    fi
    popd

    # Direnv allow
    ( cd "$worktree_dir" && direnv allow )
  fi
  return 0
}

# Create a tmux session for the git worktree branch
function create_or_attach_tmux_session() {
  local branch_name="$1"
  local worktree_dir=$WORKTREE_ROOT/$branch_name

  if tmux has-session -t "$branch_name" 2>/dev/null; then
    echo "Tmux session found"
    tmux switch -t "$branch_name"
  else
    echo "Creating tmux session..."
    tmux new-session -d -s "$branch_name" -c "$worktree_dir"
    tmux switch -t "$branch_name"
  fi
}

function lighten_color() {
  local color="$1"
  local r g b
  r=$(printf "%d" "0x${color:1:2}")
  g=$(printf "%d" "0x${color:3:2}")
  b=$(printf "%d" "0x${color:5:2}")

  # Lighten the color by 20%
  r=$((r + (255 - r) * 20 / 100))
  g=$((g + (255 - g) * 20 / 100))
  b=$((b + (255 - b) * 20 / 100))

  printf "#%02x%02x%02x\n" $r $g $b
}

# Create a code workspace file for the git worktree branch
function create_code_workspace_file() {
  local branch_name="$1"
  local code_workspaces_file=$CODE_WORKSPACES_DIR/$branch_name.code-workspace

  if [ ! -f $code_workspaces_file ]; then
    echo "Creating code workspace file..."

    local active_color=$(printf "#%06x\n" $((RANDOM % 0xFFFFFF)))
    local inactive_color=$(lighten_color "$active_color")
    local file_content=$(jq -n '{
      "folders": [
        {
          "name": "'$branch_name'",
          "path": "'$WORKTREE_ROOT'/'$branch_name'"
        }
      ],
      "settings": {
        "workbench.colorCustomizations": {
          "titleBar.activeBackground": "'$active_color'",
          "titleBar.inactiveBackground": "'$inactive_color'"
        }
      }
    }')
    echo $file_content >$code_workspaces_file
    echo "Code workspace file created: $code_workspaces_file"
  fi
}

local branch_name="$1"
[ -n "$branch_name" ] || exit 1

tmux set -g @wt_status "⟳ wt"
tmux refresh-client -S

local logfile="/tmp/wt-create-${branch_name//\//-}.log"
exec > "$logfile" 2>&1

echo "Creating worktree: $branch_name..."
create_git_worktree $branch_name || {
  tmux set -g @wt_status ""
  tmux refresh-client -S
  tmux display-popup -E -w 80% -h 60% "less '$logfile'; rm -f '$logfile'"
  exit 1
}
create_code_workspace_file $branch_name
create_or_attach_tmux_session $branch_name
tmux set -g @wt_status ""
tmux refresh-client -S
tmux display-popup -E -w 80% -h 60% "less '$logfile'; rm -f '$logfile'"
