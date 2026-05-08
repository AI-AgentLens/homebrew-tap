cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.913"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.913/agentshield_0.2.913_darwin_amd64.tar.gz"
      sha256 "c442e38a7ed7d6e35f05f195d6c91689ac96b62b3ad29a40912d24c6b1a3f356"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.913/agentshield_0.2.913_darwin_arm64.tar.gz"
      sha256 "6869951b21fd425bb4e13b98590e2dfff44a3280db34a0535d9136c4116b89d8"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.913/agentshield_0.2.913_linux_amd64.tar.gz"
      sha256 "d679526ef9733f5f549bfc279e42c4f77c500f035d88a2e11d89edf2fcd2fc09"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.913/agentshield_0.2.913_linux_arm64.tar.gz"
      sha256 "468247480531ff12b802dab544d98116a688c85898cd71edb4ab42dfc2e6940d"
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
