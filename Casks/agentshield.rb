cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.931"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.931/agentshield_0.2.931_darwin_amd64.tar.gz"
      sha256 "82ec88b4a609b130608e57de4af6523db228835a3d85fd8fb627776c5905f036"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.931/agentshield_0.2.931_darwin_arm64.tar.gz"
      sha256 "588707c993045bd3be98fef4d967c042451cc8d5fcf93e12560c24ecb824d396"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.931/agentshield_0.2.931_linux_amd64.tar.gz"
      sha256 "3b12c91692b2b5bd05efcb6234357b814b6ab5a4fde371194c87400a96b79a3f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.931/agentshield_0.2.931_linux_arm64.tar.gz"
      sha256 "a24f6d5ba5dd6e7a4b61c565aff5d8ae25f3aa7405578ff4d6a8f40083781021"
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
