cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1498"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1498/agentshield_0.2.1498_darwin_amd64.tar.gz"
      sha256 "6d9d6f6a9b001fd01bc7c6da27da1873eb58d0644d6f62d516eefe7d6f4344cf"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1498/agentshield_0.2.1498_darwin_arm64.tar.gz"
      sha256 "134dee461f64581566f6954fbdea7bc8de90d877f3cb196b5315a47f72863e84"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1498/agentshield_0.2.1498_linux_amd64.tar.gz"
      sha256 "d54dd8cd2e6a74bc044c0557072faf19fb0b25152f3cde99709e5eeaae8a36bb"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1498/agentshield_0.2.1498_linux_arm64.tar.gz"
      sha256 "262e539f70f740e778debceed1328dc45aa854b84bf21abd092b71f853f8cefd"
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
