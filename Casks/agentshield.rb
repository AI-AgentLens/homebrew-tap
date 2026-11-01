cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2618"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2618/agentshield_0.2.2618_darwin_amd64.tar.gz"
      sha256 "7f1ccfc5b5c109688872767251e1ef5cee67da897ad0c636ab9b13e913bccbc9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2618/agentshield_0.2.2618_darwin_arm64.tar.gz"
      sha256 "d47b4e0d3405cacedf0f697969aec8b8e57bd4900c1fc4c4adb1b2bddda83494"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2618/agentshield_0.2.2618_linux_amd64.tar.gz"
      sha256 "7b72c298dc300935e7f408e7c53b2ad07c4b462496be8987afe79b17e925af02"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2618/agentshield_0.2.2618_linux_arm64.tar.gz"
      sha256 "70587edf2a027d1b9c6ccaa93de9e467e4a2d5006f5fdfeb4b0013e4ae955396"
    end
  end

  # Stop the heartbeat daemon before upgrading so the old binary doesn't keep
  # running as a zombie after brew replaces it.
  #
  # Structured steps, not Ruby flight blocks: Homebrew 7.0.0 deprecated
  # preflight/postflight (Homebrew/brew#23729) and the next minor release turns
  # that into an error. These steps need Homebrew >= 6.0.16; older ones refuse
  # to load the cask. They run in Homebrew's sandbox with a throwaway HOME, so
  # home paths use base: :home (a literal ~ would name the throwaway HOME), and
  # the uid comes from id -u because a steps block allows no Ruby interpolation.
  # must_succeed: false keeps system_command's ignore-failure behaviour.
  preflight_steps do
    on_macos do
      if_path_exists "Library/LaunchAgents/com.aiagentlens.agentshield.plist", base: :home do
        run "/bin/sh",
            args:         ["-c", "exec /bin/launchctl bootout gui/$(/usr/bin/id -u)/com.aiagentlens.agentshield"],
            must_succeed: false,
            print_stderr: false
        remove "Library/LaunchAgents/com.aiagentlens.agentshield.plist", base: :home
      end
    end
  end

  postflight_steps do
    on_macos do
      run "/usr/bin/xattr",
          args:         ["-dr", "com.apple.quarantine", "{{staged_path}}/agentshield"],
          must_succeed: false
      run "/usr/bin/xattr",
          args:         ["-dr", "com.apple.quarantine", "{{staged_path}}/agentcompliance"],
          must_succeed: false
    end
  end

  uninstall launchctl: "com.aiagentlens.agentshield",
            delete:    "~/Library/LaunchAgents/com.aiagentlens.agentshield.plist"

  # brew uninstall --zap removes the agent hooks that agentshield setup wrote
  # (#4491). Zap only, never uninstall: Homebrew runs uninstall stanzas and
  # uninstall flight blocks on every upgrade and reinstall (Cask::Installer
  # start_upgrade -> uninstall_artifacts), so removing hooks there would strip
  # protection on each brew upgrade. Zap runs only on brew uninstall --zap,
  # before the binary link and the Caskroom are removed, so the staged binary
  # still runs. Each agent is non-fatal: a managed host refuses --disable and
  # keeps its hooks, which belong to the MDM. ~/.agentshield is kept on
  # purpose: it holds the audit log, which is evidence.
  zap script: {
    executable:   "/bin/sh",
    args:         ["-c", <<~'SH', "#{staged_path}/agentshield"],
      bin="$0"
      PATH="$(dirname "$bin"):$PATH"; export PATH
      for agent in claude-code gemini-cli codex copilot-cli windsurf cursor openclaw mcp; do
        echo "==> agentshield setup $agent --disable"
        "$bin" setup "$agent" --disable || echo "    not removed (exit $?); on a managed host your administrator removes it"
      done
      echo "==> ~/.agentshield kept (policy and audit log)"
    SH
    must_succeed: false,
  }

  caveats <<~EOS
    Two tools installed:
      agentshield      — Runtime security gateway for AI agents
      agentcompliance  — Local compliance scanner (semgrep-based)

    Quick start:
      agentshield setup
      agentshield login

    To uninstall and remove the agent hooks setup wrote:
      brew uninstall --zap --cask agentshield
    A plain brew uninstall leaves the hooks. ~/.agentshield (audit log) is kept.
  EOS
end
