cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1648"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1648/agentshield_0.2.1648_darwin_amd64.tar.gz"
      sha256 "bc0a52234d6c9e827d07ce355a59642305271391ac5e11445beb414b791f46f5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1648/agentshield_0.2.1648_darwin_arm64.tar.gz"
      sha256 "3ce0524ab5e71f11c575947d5d61be44ec0fc34793446a5ea496cd4d308ed1b3"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1648/agentshield_0.2.1648_linux_amd64.tar.gz"
      sha256 "10bb2678036f15c8ab4fbacbe9e9095665228ba9c56996209d2054a7d4c16f32"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1648/agentshield_0.2.1648_linux_arm64.tar.gz"
      sha256 "09501c686ea0f3255809a480d61f2c36cb894ff2b0280ab7e61acfd617d5d4bd"
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
