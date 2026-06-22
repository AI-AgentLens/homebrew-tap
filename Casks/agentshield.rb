cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1400"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1400/agentshield_0.2.1400_darwin_amd64.tar.gz"
      sha256 "3654cab5d6b6b944ff38c9ddd9344a6a86ab8fceda8452e6bd763ea2324c772a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1400/agentshield_0.2.1400_darwin_arm64.tar.gz"
      sha256 "1248d8de71d9f32a7be476a4a23bc5668030ba6237f3bbb078204860a6716e80"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1400/agentshield_0.2.1400_linux_amd64.tar.gz"
      sha256 "6547a647dbb72a36c3127e59cc67835df239429957a32fa93b0bea59bce936b3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1400/agentshield_0.2.1400_linux_arm64.tar.gz"
      sha256 "1303c091d80afeb8e13cf4cce78e0b5968f744a568f1e3ccd98a67ffa14705d2"
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
