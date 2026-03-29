cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.191"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.191/agentshield_0.2.191_darwin_amd64.tar.gz"
      sha256 "ee099472e7183bcbdcd514146b443ff4d193a8ad136e0d88708c96c122c75be7"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.191/agentshield_0.2.191_darwin_arm64.tar.gz"
      sha256 "a4aebc9935ae24ea9891d4545fe2fb98aefdfdf3e782bb28eceb6b0ff860f6ad"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.191/agentshield_0.2.191_linux_amd64.tar.gz"
      sha256 "71e0f65a6a6ae78c69e5c7c9e1664970122b2a71d5e8065b16f5811d40675dfb"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.191/agentshield_0.2.191_linux_arm64.tar.gz"
      sha256 "efb6f90a4ae56b58a83e32b9c361c14b1f5efd2a210cee422f67bfb5a23cfec9"
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
