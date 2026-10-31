#!/bin/bash
# Homebrew 7 leg of the clean-Mac install test.
#
# What it is for: since Homebrew 6.0.0 a third-party tap is untrusted until
# `brew trust` (https://docs.brew.sh/Tap-Trust). The other legs set
# HOMEBREW_NO_AUTO_UPDATE and so test whatever Homebrew the runner image ships.
# This leg updates Homebrew first, so it sees what a customer who keeps
# Homebrew current sees (AI-AgentLens/AI_Agent_Shield#4667).
#
# What it is NOT for: judging the untrusted installs. `measure` records what
# Homebrew does, verbatim; the workflow runs it with continue-on-error. The
# trusted install is judged by clean-install.sh.
#
# Usage:
#   homebrew7.sh update            brew update, print the version, and fail
#                                  unless it is Homebrew 7 or later
#   homebrew7.sh measure <case>    one install without trust, on a Mac that has
#                                  never tapped ai-agentlens/tap; exits with the
#                                  install's exit status
#
# Cases (the two install spellings in use):
#   qualified       brew install --cask ai-agentlens/tap/agentshield
#   tap-then-name   brew tap AI-AgentLens/tap && brew install --cask agentshield

set -u

SUMMARY=${GITHUB_STEP_SUMMARY:-/dev/null}
WORK=$(mktemp -d)
say() { printf '%s\n' "$@" >> "$SUMMARY"; }

# fenced <file> <max lines>: the file's lines in a code block, verbatim.
fenced() {
  say '```'
  if [ -s "$1" ]; then head -n "$2" "$1" >> "$SUMMARY"; else say "(no output)"; fi
  say '```'
}

# major_of "<brew --version first line>": the major version, or nothing.
major_of() { printf '%s\n' "$1" | sed -n 's/^Homebrew \([0-9][0-9]*\)\..*/\1/p'; }

update() {
  brew update > "$WORK/update.log" 2>&1
  rc=$?
  cat "$WORK/update.log"
  brew --version > "$WORK/version.txt" 2>&1
  ver=$(head -1 "$WORK/version.txt")
  major=$(major_of "$ver")

  say "### Homebrew this leg ran" ""
  fenced "$WORK/version.txt" 5
  say "\`brew update\` exited $rc. Its lines about trust:" ""
  grep -i 'trust' "$WORK/update.log" > "$WORK/update-trust.txt"
  fenced "$WORK/update-trust.txt" 20

  # Vacuity guard: a "Homebrew 7 leg" that ran Homebrew 6 measured nothing,
  # and a green run would say it had.
  if [ -z "$major" ] || [ "$major" -lt 7 ]; then
    say "" "**FAIL: this leg ran \`$ver\`, not Homebrew 7 or later. Nothing below measures Homebrew 7.**"
    echo "::error::Homebrew 7 leg ran '$ver'; it measured nothing about Homebrew 7"
    exit 1
  fi
  echo "Homebrew major version $major"
}

measure() {
  case "${1:-}" in
    qualified)     cmd='brew install --cask ai-agentlens/tap/agentshield' ;;
    tap-then-name) cmd='brew tap AI-AgentLens/tap && brew install --cask agentshield' ;;
    *) echo "unknown case '${1:-}'"; exit 2 ;;
  esac

  # A leftover tap or binary would make this measure the runner, not a fresh Mac.
  if brew tap | grep -qi '^ai-agentlens/' || command -v agentshield >/dev/null 2>&1; then
    say "**FAIL: ai-agentlens/tap or agentshield is already present; this is not a fresh Mac.**"
    exit 2
  fi

  # Run under a pseudo-terminal (script) so a prompt, if Homebrew asks one,
  # shows up as it would in a customer's terminal. stdin is empty, so a prompt
  # reads end-of-file instead of waiting; the alarm bounds anything that hangs.
  raw="$WORK/raw.log"
  limit=${MEASURE_TIMEOUT:-900}
  perl -e 'alarm shift; exec @ARGV' "$limit" \
    script -q "$raw" /bin/sh -c "$cmd; rc=\$?; echo; echo install-exit=\$rc" < /dev/null
  # Split carriage-return progress updates into lines, and drop terminal
  # escapes and the ^D the terminal echoes for the empty stdin.
  perl -pe 's/\e\[[0-9;?]*[A-Za-z]//g; s/\^D\x08*//g; s/\r(?!\n)/\n/g; s/\r//g' "$raw" | grep -v '^[[:space:]]*$' > "$WORK/install.log"
  rc=$(sed -n 's/^install-exit=\([0-9][0-9]*\)$/\1/p' "$WORK/install.log" | tail -1)
  grep -v '^install-exit=' "$WORK/install.log" > "$WORK/out.log"

  say "### Install without trust: \`$cmd\`" ""
  if [ -n "$rc" ]; then
    say "Exit code: **$rc**" ""
  else
    rc=124
    say "Exit code: **none**: the command did not finish within $limit s (the output below ends where it stopped)" ""
  fi
  say "Lines about trust, refusals, errors and the install result, verbatim:" ""
  grep -iE 'trust|refus|error|warning|tapp|install|caveat|==>' "$WORK/out.log" > "$WORK/relevant.txt"
  fenced "$WORK/relevant.txt" 40

  # What the install left behind, and whether the upgrade path can load the cask.
  installed=$(brew list --cask --versions agentshield 2>&1 < /dev/null | head -1)
  brew trust < /dev/null > "$WORK/trusted.txt" 2>&1
  brew untrust < /dev/null > "$WORK/untrusted.txt" 2>&1
  brew upgrade --cask --dry-run agentshield < /dev/null > "$WORK/upgrade.txt" 2>&1
  up_rc=$?
  say "After the install:" ""
  say "\`brew list --cask --versions agentshield\`:"
  printf '%s\n' "${installed:-(nothing)}" > "$WORK/installed.txt"
  fenced "$WORK/installed.txt" 1
  say "\`brew trust\` (lists trusted entries):"
  fenced "$WORK/trusted.txt" 15
  say "\`brew untrust\` (lists untrusted entries):"
  fenced "$WORK/untrusted.txt" 15
  say "\`brew upgrade --cask --dry-run agentshield\` exited $up_rc:"
  fenced "$WORK/upgrade.txt" 10

  say "<details><summary>Full install output ($(wc -l < "$WORK/out.log" | tr -d ' ') lines)</summary>" ""
  fenced "$WORK/out.log" 200
  say "</details>" ""

  cat "$WORK/out.log"
  echo "install exit code: $rc"
  exit "$rc"
}

case "${1:-}" in
  update)  update ;;
  measure) measure "${2:-}" ;;
  *) echo "usage: $0 update | measure <qualified|tap-then-name>"; exit 2 ;;
esac
