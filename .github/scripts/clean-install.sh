#!/bin/bash
# Clean-Mac install test for the agentshield cask.
#
# What it is for: every release a customer can install is installed on a clean
# Mac, following the "Install and first block" page step by step (docs-site
# docs/agentshield/getting-started.md in the aiagentlens repo), and the run ends
# with a known-bad action being stopped. "brew install exited 0" proves nothing:
# the failures that matter are silent (a binary macOS kills on first run, a hook
# that is not registered, a mode the user was not told about).
#
# What it is NOT for: rule coverage (Shield's CI does that), the logged-in
# premium path (needs a SaaS login, not wired yet), or a real agent calling the
# hook (that is a separate canary).
#
# If it goes red, a customer following the docs on a clean Mac hits the same
# failure. Removing it removes the only check that installs the published cask.
#
# Usage:
#   clean-install.sh             on a clean runner: install, check, uninstall
#   clean-install.sh --no-brew   checks only, against `agentshield` on PATH and
#                                the current HOME (use a scratch HOME locally)

set -u

NO_BREW=0
[ "${1:-}" = "--no-brew" ] && NO_BREW=1

SUMMARY=${GITHUB_STEP_SUMMARY:-/dev/null}
WORK=$(mktemp -d)
FAILS=0

row() { printf '| %s | %s | %s |\n' "$1" "$2" "$3" >> "$SUMMARY"; }
ok()   { echo "PASS  $1: $2"; row "$1" "pass" "$2"; }
bad()  { echo "FAIL  $1: $2"; row "$1" "**FAIL**" "$2"; FAILS=$((FAILS + 1)); }
info() { echo "INFO  $1: $2"; row "$1" "info" "$2"; }

printf '| Check | Result | Detail |\n| --- | --- | --- |\n' >> "$SUMMARY"
info "runner" "macOS $(sw_vers -productVersion) on $(uname -m)"

# The known-bad action is assembled from parts so this file never holds the
# command as one string (AgentShield on a developer's machine reads the files
# an agent writes). It is only ever evaluated, never run.
CANARY=$(printf '%s %s %s' rm -rf /)

# payload <file> <command>: the PreToolUse JSON Claude Code sends the hook.
payload() {
  python3 - "$1" "$2" "$WORK" <<'PY'
import json, sys
json.dump({"session_id": "clean-install", "hook_event_name": "PreToolUse",
           "tool_name": "Bash", "tool_input": {"command": sys.argv[2]},
           "cwd": sys.argv[3]}, open(sys.argv[1], "w"))
PY
}
payload "$WORK/bad.json" "$CANARY"
payload "$WORK/ok.json" "ls -la"

# last_event: decision fields of the newest audit line, as "decision original rules".
last_event() {
  python3 - "$HOME/.agentshield/audit.jsonl" <<'PY'
import json, sys
try:
    lines = [l for l in open(sys.argv[1]) if l.strip()]
    d = json.loads(lines[-1])
    print(d.get("decision", "-"), d.get("original_decision") or "-",
          ",".join(d.get("triggered_rules") or []) or "-")
except Exception as e:
    print("unreadable", "-", type(e).__name__)
PY
}

# hook <payload>: run the hook as Claude Code does; sets HOOK_RC and HOOK_ERR.
hook() {
  agentshield hook < "$1" > "$WORK/hook.out" 2> "$WORK/hook.err"
  HOOK_RC=$?
  HOOK_ERR=$(head -c 300 "$WORK/hook.err" | tr '\n' ' ')
}

# --- 0. The machine is clean ---------------------------------------------------
if [ "$NO_BREW" = 0 ]; then
  if command -v agentshield >/dev/null 2>&1 || [ -e "$HOME/.agentshield" ]; then
    bad "clean machine" "agentshield or ~/.agentshield already present; the run proves nothing"
    exit 1
  fi
  ok "clean machine" "no agentshield on PATH, no ~/.agentshield"

  # --- 1. Install, exactly as the docs say -------------------------------------
  t0=$(date +%s)
  brew tap AI-AgentLens/tap && brew trust AI-AgentLens/tap 2>/dev/null; brew install --cask agentshield
  rc=$?
  secs=$(( $(date +%s) - t0 ))
  if [ "$rc" -ne 0 ]; then
    bad "install" "brew install --cask agentshield exited $rc after ${secs}s"
    exit 1
  fi
  installed=$(brew list --cask --versions agentshield 2>/dev/null | awk '{print $NF}')
  ok "install" "cask ${installed:-?} in ${secs}s"
  # On a cask bump this runs on the pushed commit; a newer bump may already have
  # landed, so a difference is reported, not failed.
  if [ -f Casks/agentshield.rb ]; then
    want=$(sed -n 's/^ *version "\(.*\)"/\1/p' Casks/agentshield.rb | head -1)
    [ -n "$want" ] && [ "$want" != "$installed" ] && \
      info "version" "installed $installed, this commit's cask says $want (a newer bump may have landed)"
  fi
fi

# --- 2. The binaries run ----------------------------------------------------------
# A binary macOS refuses on a fresh Mac dies here (SIGKILL, exit 137) or never starts.
if out=$(agentshield version 2>&1); then
  ok "agentshield runs" "$(echo "$out" | head -2 | tr '\n' ' ')"
else
  bad "agentshield runs" "exit $?: $(echo "$out" | head -c 200)"
  exit 1
fi
if out=$(agentcompliance version 2>&1); then
  ok "agentcompliance runs" "$(echo "$out" | head -1)"
else
  bad "agentcompliance runs" "exit $?: $(echo "$out" | head -c 200)"
fi

# --- 3. Connect it to Claude Code (docs step 2) ----------------------------------
out=$(agentshield setup claude-code 2>&1); rc=$?
if [ "$rc" -ne 0 ]; then
  bad "setup claude-code" "exit $rc: $(echo "$out" | tail -3 | tr '\n' ' ')"
else
  ok "setup claude-code" "exit 0"
fi
if echo "$out" | grep -q "starts in audit-only"; then
  ok "told about audit-only" "setup says a new install starts in audit-only"
else
  bad "told about audit-only" "setup output does not say the install starts in audit-only"
fi
hook_check=$(python3 - "$HOME/.claude/settings.json" <<'PY'
import json, sys
try:
    d = json.load(open(sys.argv[1]))
except Exception as e:
    print("settings.json unreadable: " + type(e).__name__); sys.exit()
for m in (d.get("hooks") or {}).get("PreToolUse", []) or []:
    for h in m.get("hooks", []) or []:
        text = " ".join([str(h.get("command", ""))] + [str(a) for a in h.get("args", []) or []])
        if "agentshield" in text and "hook" in text:
            print("OK " + text); sys.exit()
print("no PreToolUse hook runs agentshield hook")
PY
)
case "$hook_check" in
  OK*) ok "hook registered" "${hook_check#OK }" ;;
  *)   bad "hook registered" "$hook_check" ;;
esac

# --- 4. The self-test (docs step 3) ----------------------------------------------
out=$(agentshield scan 2>&1)
if echo "$out" | grep -qE "All [0-9]+ tests passed"; then
  ok "agentshield scan" "$(echo "$out" | grep -oE 'All [0-9]+ tests passed')"
else
  bad "agentshield scan" "$(echo "$out" | grep -E 'passed|failed|❌' | head -3 | tr '\n' ' ')"
fi
# In audit-only the self-test still prints BLOCK for the dangerous commands; the
# mode line at its top is what tells the user nothing is being stopped yet.
if echo "$out" | grep -q "^Mode: audit-only"; then
  ok "scan shows the mode" "the self-test's first lines say audit-only"
else
  bad "scan shows the mode" "the self-test does not say audit-only, but reports BLOCKs"
fi

# --- 5. Fresh install: the known-bad action is recorded, not stopped --------------
hook "$WORK/bad.json"; read -r dec orig rules <<< "$(last_event)"
if [ "$HOOK_RC" -eq 0 ] && [ "$dec" = "AUDIT" ] && [ "$orig" = "BLOCK" ]; then
  ok "audit-only canary" "runs, recorded as AUDIT (would have been BLOCK by $rules)"
else
  bad "audit-only canary" "hook exit $HOOK_RC, recorded $dec (original $orig); expected exit 0, AUDIT, original BLOCK"
fi

# --- 6. Turn on enforcement (docs step 4), then it is stopped ----------------------
printf 'mode: enforce\n' >> "$HOME/.agentshield/agentshield.yaml"
hook "$WORK/bad.json"; read -r dec orig rules <<< "$(last_event)"
if [ "$HOOK_RC" -eq 2 ] && [ "$dec" = "BLOCK" ]; then
  ok "enforce canary" "blocked (exit 2) by $rules"
else
  bad "enforce canary" "hook exit $HOOK_RC, recorded $dec; expected exit 2, BLOCK. stderr: $HOOK_ERR"
fi
# Negative control: a hook that blocks everything would pass the check above.
hook "$WORK/ok.json"; read -r dec orig rules <<< "$(last_event)"
if [ "$HOOK_RC" -eq 0 ] && [ "$dec" = "ALLOW" ]; then
  ok "harmless command" "ls -la allowed in enforce mode"
else
  bad "harmless command" "hook exit $HOOK_RC, recorded $dec; expected exit 0, ALLOW"
fi

# --- 7. Hook wall time, as the agent waits for it (not logged in) -----------------
ms=$(python3 - "$WORK/ok.json" <<'PY'
import statistics, subprocess, sys, time
ts = []
for _ in range(15):
    t = time.perf_counter()
    subprocess.run(["agentshield", "hook"], stdin=open(sys.argv[1]), capture_output=True)
    ts.append((time.perf_counter() - t) * 1000)
print(f"median {statistics.median(ts):.0f} ms, max {max(ts):.0f} ms over 15 calls")
PY
)
info "hook wall time" "$ms"

# --- 8. Uninstall with --zap removes the hooks (AI_Agent_Shield#4491) -------------
# A plain `brew uninstall` leaves the hooks setup wrote, and Claude Code then
# reports a hook error on every tool call and runs the tool unchecked. The
# cask's zap stanza runs `agentshield setup <agent> --disable` for every agent.
# The removal lives in zap, never in uninstall: Homebrew runs uninstall steps on
# every `brew upgrade`, so removing hooks there would strip protection on each
# upgrade. ~/.agentshield is kept on purpose (the audit log is evidence).
# Not checked yet: that `brew upgrade` between two releases that both carry the
# stanza keeps the hooks (follow-up).

# hooks_naming_agentshield: hook entries in ~/.claude/settings.json, any event,
# whose command or args name agentshield.
hooks_naming_agentshield() {
  python3 - "$HOME/.claude/settings.json" <<'PY'
import json, sys
try:
    d = json.load(open(sys.argv[1]))
except FileNotFoundError:
    print(0); sys.exit()
except Exception as e:
    print("unreadable:" + type(e).__name__); sys.exit()
n = 0
for groups in (d.get("hooks") or {}).values():
    for g in groups or []:
        for h in (g or {}).get("hooks", []) or []:
            text = " ".join([str(h.get("command", ""))] + [str(a) for a in h.get("args", []) or []])
            n += "agentshield" in text
print(n)
PY
}

if [ "$NO_BREW" = 0 ]; then
  bin=$(command -v agentshield)
  before=$(hooks_naming_agentshield)
  # Control: the count below is only meaningful if there was a hook to remove.
  if [ "$before" = "0" ] || [ "${before#unreadable}" != "$before" ]; then
    bad "zap removes hooks" "before uninstall, settings.json had ${before} hook(s) naming agentshield; the check would prove nothing"
  elif brew uninstall --zap --cask agentshield > "$WORK/zap.out" 2>&1; then
    after=$(hooks_naming_agentshield)
    if [ -e "$bin" ]; then gone="still there"; else gone="removed"; fi
    if [ "$after" = "0" ]; then
      ok "zap removes hooks" "brew uninstall --zap: $before hook(s) naming agentshield before, 0 after; binary $gone"
    else
      bad "zap removes hooks" "brew uninstall --zap left $after hook(s) naming agentshield (had $before); binary $gone. $(grep -E 'setup|not removed' "$WORK/zap.out" | head -3 | tr '\n' ' ')"
    fi
    if [ -d "$HOME/.agentshield" ]; then
      ok "zap keeps ~/.agentshield" "the audit log is kept on purpose"
    else
      bad "zap keeps ~/.agentshield" "~/.agentshield was removed; it holds the audit log"
    fi
  else
    bad "zap removes hooks" "brew uninstall --zap --cask agentshield failed: $(tail -3 "$WORK/zap.out" | tr '\n' ' ')"
  fi
fi

rm -rf "$WORK"
if [ "$FAILS" -gt 0 ]; then
  echo "$FAILS check(s) failed"
  exit 1
fi
echo "all checks passed"
