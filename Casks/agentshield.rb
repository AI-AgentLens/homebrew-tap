cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.851"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.851/agentshield_0.2.851_darwin_amd64.tar.gz"
      sha256 "b0958ca6b6215f4f673ffd3f0575c90a9b5d319951ebff7028fc44914539ab89"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.851/agentshield_0.2.851_darwin_arm64.tar.gz"
      sha256 "eecf302c83ef7fd7f9dea44b508c2c3bb5477e0f5d299f7a3102704f4bdbbf3e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.851/agentshield_0.2.851_linux_amd64.tar.gz"
      sha256 "ee948f0868c82552a85fa5150155192e8d314a74a4696079df94977fea69a94f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.851/agentshield_0.2.851_linux_arm64.tar.gz"
      sha256 "f14ed88f5be7584ff8d296ed5e236ad6faf458698f70b652f31a786a23a57334"
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
