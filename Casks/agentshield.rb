cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1930"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1930/agentshield_0.2.1930_darwin_amd64.tar.gz"
      sha256 "103223d9a7f467545ca76e3790aae5b8d2451b4a308748bb2725b3e7071cd487"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1930/agentshield_0.2.1930_darwin_arm64.tar.gz"
      sha256 "2ded484a588429fd0ad41b429dafc00c908326fcb4e8b12a80376dd6b011b30f"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1930/agentshield_0.2.1930_linux_amd64.tar.gz"
      sha256 "0dff9fc9d1d9f262b0ef71e7d8a2f13c402159ffdddd5529b70f6fe3d0bbff4c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1930/agentshield_0.2.1930_linux_arm64.tar.gz"
      sha256 "8d24e89318be74f80d8e545abcc09cabe650f3cc7f2ef323b2e9c5516fde5346"
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
