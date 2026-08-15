#!/usr/bin/env bash
# sync_repos.sh — safe cross-repo sync for the "sync everything" skill.
#
# For each eMed repo (ai_info first — skills/plans live there), fetches origin and
# does a FAST-FORWARD-ONLY pull of the repo's CURRENT branch. It NEVER merges,
# rebases, force-pushes, resets, switches branches, stashes, or commits. Any repo
# that is diverged, detached, has no upstream, or whose local changes would block a
# fast-forward is SKIPPED and reported — never forced. Untracked/uncommitted work
# is left untouched.
#
# It always prints a full ai_info inventory (skills + plans-with-status) at the end,
# independent of whether anything was pulled, so the caller can reconcile it against
# what it already knows and read anything unfamiliar (a skill/plan can be on disk
# from an out-of-band pull or a prior sync even when this run reports UP_TO_DATE).
#
# Repos are resolved as siblings of ai_info (this script lives in ai_info/skills/),
# so the caller's cwd does not matter.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE="$(cd "$SCRIPT_DIR/../.." && pwd)"
REPOS="ai_info emed_app emed_sql emed_etl"

for r in $REPOS; do
  d="$BASE/$r"
  echo "=== $r ==="
  if [ ! -d "$d/.git" ]; then echo "status: NOT_CLONED (skipped)"; echo; continue; fi

  # Surface fetch failures (offline/VPN) instead of silently proceeding on stale refs.
  if ! git -C "$d" fetch origin --prune -q; then
    echo "status: WARN_FETCH_FAILED (offline/VPN? — ahead/behind below may be stale)"
  fi

  br="$(git -C "$d" rev-parse --abbrev-ref HEAD 2>/dev/null)"
  echo "branch: $br"
  if [ "$br" = "HEAD" ]; then echo "status: SKIP_DETACHED_HEAD"; echo; continue; fi

  if ! git -C "$d" rev-parse --abbrev-ref --symbolic-full-name '@{upstream}' >/dev/null 2>&1; then
    echo "status: SKIP_NO_UPSTREAM (branch never pushed, or its remote branch was deleted/merged — to update, switch to main and re-run)"; echo; continue; fi

  behind="$(git -C "$d" rev-list --count 'HEAD..@{upstream}' 2>/dev/null)"
  ahead="$(git -C "$d" rev-list --count '@{upstream}..HEAD' 2>/dev/null)"
  before="$(git -C "$d" rev-parse HEAD)"

  if [ "${behind:-0}" = "0" ]; then
    echo "status: UP_TO_DATE (ahead ${ahead:-0})"
  elif [ "${ahead:-0}" != "0" ]; then
    echo "status: SKIP_DIVERGED (behind $behind, ahead $ahead) — resolve manually (rebase/merge); not auto-synced"
  elif git -C "$d" pull --ff-only -q 2>/dev/null; then
    after="$(git -C "$d" rev-parse HEAD)"
    echo "status: PULLED $behind commit(s)  ${before:0:9}..${after:0:9}"
    git -C "$d" --no-pager log --format='  - %h %s' "$before..$after" 2>/dev/null | head -25
    if [ "$r" = "ai_info" ]; then
      changed="$(git -C "$d" --no-pager diff --name-status "$before..$after" -- skills/ plans/ org/ 2>/dev/null)"
      [ -n "$changed" ] && { echo "ai_info changes this pull (skills/plans/org — R=renamed, A=added, M=modified, D=deleted):"; printf '%s\n' "$changed" | sed 's/^/  /'; }
    fi
  else
    echo "status: SKIP_FF_BLOCKED (fast-forward pull failed — likely local changes; commit or stash them, then re-run)"
  fi
  echo
done

# Full ai_info inventory — printed EVERY run regardless of sync outcome, so the caller can reconcile
# it against what it already has loaded and read anything it doesn't recognize.
ai="$BASE/ai_info"
if [ -d "$ai/.git" ]; then
  echo "=== ai_info inventory (reconcile against what you already know; read anything unfamiliar) ==="
  echo "skills:"
  for f in "$ai"/skills/*.md; do [ -e "$f" ] && echo "  - $(basename "$f")"; done
  echo "plans (name — status):"
  for f in "$ai"/plans/*.md; do
    [ -e "$f" ] || continue
    b="$(basename "$f")"; [ "$b" = "README.md" ] && continue
    st="$(grep -m1 '^status:' "$f" 2>/dev/null | sed 's/^status:[[:space:]]*//')"
    echo "  - $b — ${st:-?}"
  done
fi
echo "=== done ==="
