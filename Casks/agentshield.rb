cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1889"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1889/agentshield_0.2.1889_darwin_amd64.tar.gz"
      sha256 "066608a25f248dc496261976829ba308f56ce072e365503c95e26b649f8e59d9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1889/agentshield_0.2.1889_darwin_arm64.tar.gz"
      sha256 "f831d5cd0ebb0a976cf111ecc0070a0813ca6a817a6c85f6e15b4bb1b87ec443"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1889/agentshield_0.2.1889_linux_amd64.tar.gz"
      sha256 "760b34848b751cda35077b664156494c6f15463ce22f8ecf21bc9dc765bdeca6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1889/agentshield_0.2.1889_linux_arm64.tar.gz"
      sha256 "1c5fd8e83b825bf79f7ff04e31b7dc4dc049dfa8a475925c9a42f29894c59493"
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

  caveats <<~EOS
    Two tools installed:
      agentshield      — Runtime security gateway for AI agents
      agentcompliance  — Local compliance scanner (semgrep-based)

    Quick start:
      agentshield setup
      agentshield login
  EOS
end
