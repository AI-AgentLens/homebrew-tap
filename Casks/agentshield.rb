cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2051"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2051/agentshield_0.2.2051_darwin_amd64.tar.gz"
      sha256 "af85ae7520034f822ff42ef12c8a54e686ada46d229440c53531a6f88e8c4ab2"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2051/agentshield_0.2.2051_darwin_arm64.tar.gz"
      sha256 "8c610c26f5888238be756678ce1eb48b294cf68426018c815f8363de291a8e3f"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2051/agentshield_0.2.2051_linux_amd64.tar.gz"
      sha256 "9cf15e88a9829949db0f9f96f574e282fe5de4e46b1c51a1a9b21c6b55107bbe"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2051/agentshield_0.2.2051_linux_arm64.tar.gz"
      sha256 "4cd1e43aec2ca2713116aa51941d5aba4642d172a5f43a28d4c3737f6b282ad1"
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
