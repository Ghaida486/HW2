#!/bin/bash
# Run independent strategies together, track their PIDs, wait, then pipe to refine.
set -euo pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd)
interests=${1:-$(cat "$ROOT/data/interests.txt")}
mode=${2:-all}
TMP=$(mktemp -d)
pids=()
cleanup() {
  set +u  # Bash 3.2 treats an empty array as unset under nounset.
  for pid in "${pids[@]}"; do kill "$pid" 2>/dev/null || true; done
  rm -rf "$TMP"
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
names=(history interests discovery)
files=(recommend_from_history recommend_from_interests recommend_for_discovery)
for i in 0 1 2; do
  bash "$ROOT/recommendations/${files[$i]}.sh" "$interests" > "$TMP/$i.tsv" &
  pids+=("$!")
  printf '%s: running\n' "${names[$i]}" >&2
done
start=$SECONDS
while true; do
  active=0
  for pid in "${pids[@]}"; do
    if kill -0 "$pid" 2>/dev/null; then active=$((active+1)); fi
  done
  [[ $active -gt 0 ]] || break
  printf '\rWorking: %s strategies active | %ss elapsed   ' "$active" "$((SECONDS-start))" >&2
  sleep 0.2
done
printf '\n' >&2
failed=0
for i in 0 1 2; do
  if wait "${pids[$i]}"; then
    printf '%s: done\n' "${names[$i]}" >&2
  else
    printf '%s: failed\n' "${names[$i]}" >&2; failed=1
  fi
done
pids=()
[[ $failed -eq 0 ]] || exit 1
if [[ "$mode" == discovery ]]; then
  cat "$TMP/2.tsv" | bash "$ROOT/recommendations/refine_recommendations.sh"
else
  cat "$TMP/0.tsv" "$TMP/1.tsv" "$TMP/2.tsv" | bash "$ROOT/recommendations/refine_recommendations.sh"
fi
