cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.654"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.654/agentshield_0.2.654_darwin_amd64.tar.gz"
      sha256 "32ed32bf31a57a54701b48bf02200e9b4f5224dde76f83c1ba4ba3533a8f9446"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.654/agentshield_0.2.654_darwin_arm64.tar.gz"
      sha256 "59f89d8de6468ff4592c51d29af707b0c63b7016a057c0d159cc0126e3df67d9"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.654/agentshield_0.2.654_linux_amd64.tar.gz"
      sha256 "0e69a653cb91eb15d4144de34b9e8cab1db8075f38828783bed3730c3f49229b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.654/agentshield_0.2.654_linux_arm64.tar.gz"
      sha256 "20b547173ff729b26755699ffd4028c601a5b5bcc8e2ced4ae715f23d67c8f89"
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
