#!/bin/zsh

MAIN_REPO="${GIT_MAIN_REPO:-$HOME/repos/main}"
SCRIPT_DIR="${0:A:h}"

trap 'echo ""; echo "Press any key to exit..."; read -k1' EXIT

pushd "$MAIN_REPO" >/dev/null 2>&1 || { echo "Error: Cannot access main repo at $MAIN_REPO"; exit 1; }

echo "Fetching latest origin/main..."
git fetch origin main --quiet 2>/dev/null

# Collect all worktrees excluding main
worktrees=()
while IFS= read -r line; do
  worktrees+=("$line")
done < <(git worktree list --porcelain | awk '
  /^worktree / { path=$2 }
  /^branch / {
    branch=$2
    sub(/refs\/heads\//, "", branch)
    if (branch != "main") print branch
  }
')

popd >/dev/null 2>&1

if [ ${#worktrees[@]} -eq 0 ]; then
  echo "No worktrees found (excluding main)."
  exit 0
fi

echo "Checking ${#worktrees[@]} worktree(s) against main...\n"

merged=()
reasons=()
for branch in "${worktrees[@]}"; do
  echo -n "  Checking '$branch'... "
  pushd "$MAIN_REPO" >/dev/null 2>&1

  # Check 1: branch tip is a direct ancestor of origin/main (merge commit strategy)
  if git merge-base --is-ancestor "$branch" origin/main 2>/dev/null; then
    merged+=("$branch")
    reasons+=("merged into main")
    echo "merged"
    popd >/dev/null 2>&1
    continue
  fi

  # Check 2: ask GitHub if there's a merged PR for this branch (handles squash/rebase)
  # Only runs if the branch has an upstream configured — i.e. it was actually pushed.
  # This prevents matching old merged PRs that happen to share the same branch name.
  upstream=$(git rev-parse --abbrev-ref "$branch@{upstream}" 2>/dev/null)
  if [[ -n "$upstream" ]]; then
    pr_state=$(gh pr list --head "$branch" --state merged --json number --jq 'length' 2>/dev/null)
    if [[ "$pr_state" =~ ^[1-9] ]]; then
      merged+=("$branch")
      reasons+=("PR merged on GitHub")
      echo "PR merged"
      popd >/dev/null 2>&1
      continue
    fi
  fi

  echo "active"
  popd >/dev/null 2>&1
done

if [ ${#merged[@]} -eq 0 ]; then
  echo "\nNo merged worktrees found. Nothing to prune."
  exit 0
fi

echo "\nFound ${#merged[@]} merged worktree(s) to prune:\n"

deleted=0
for (( i = 1; i <= ${#merged[@]}; i++ )); do
  branch="${merged[$i]}"
  reason="${reasons[$i]}"
  echo -n "  Delete '$branch' ($reason)? [y/N] "
  read -k1 answer
  echo ""
  if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
    echo "  Deleting '$branch'..."
    "$SCRIPT_DIR/git-delete-worktree.sh" "$branch" 2>&1 | sed 's/^/    /'
    (( deleted++ )) || true
  else
    echo "  Skipped '$branch'."
  fi
  echo ""
done

echo "Done. Deleted $deleted / ${#merged[@]} merged worktree(s)."
