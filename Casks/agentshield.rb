cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2535"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2535/agentshield_0.2.2535_darwin_amd64.tar.gz"
      sha256 "ba0ae67143826d44974f3966da9767411fb255d15602c98b46522fb3ad2345e1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2535/agentshield_0.2.2535_darwin_arm64.tar.gz"
      sha256 "d70622f0477829613069e640dbed18aa57a3a8d084a0d17f7b0330c867f7aa28"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2535/agentshield_0.2.2535_linux_amd64.tar.gz"
      sha256 "9b8d2f76fdbcc8db714009f6bcf4f27f1d6a64f290522431d3a379c1981ddd00"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2535/agentshield_0.2.2535_linux_arm64.tar.gz"
      sha256 "e524559d85fc440b1ed628f725fa4f0c2e0909f5129da705dabc18f6b6449cf9"
    end
  end

  # Stop the heartbeat daemon before upgrading so the old binary doesn't keep
  # running as a zombie after brew replaces it.
  preflight do
    if OS.mac?
      plist = File.expand_path("~/Library/LaunchAgents/com.aiagentlens.agentshield.plist")
      if File.exist?(plist)
        system_command "/bin/launchctl", args: ["bootout", "gui/#{Process.uid}/com.aiagentlens.agentshield"], print_stderr: false
        File.delete(plist) if File.exist?(plist)
      end
    end
  end

  postflight do
    if OS.mac?
      system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{staged_path}/agentshield"]
      system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{staged_path}/agentcompliance"]
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
