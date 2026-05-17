cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1011"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1011/agentshield_0.2.1011_darwin_amd64.tar.gz"
      sha256 "9d791b50f3da935a3aba364790c94e732eeef13abbd0fed3525f8572c9949ceb"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1011/agentshield_0.2.1011_darwin_arm64.tar.gz"
      sha256 "47b2a5821b269dc95a5ec1fe1661f5dd3ba6c9cf774ae143a7ec08cbd19f1e3a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1011/agentshield_0.2.1011_linux_amd64.tar.gz"
      sha256 "c5fa07f88da24ddd38ade0b25b564a003d129ae516e80ccff35224ac5b8d2add"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1011/agentshield_0.2.1011_linux_arm64.tar.gz"
      sha256 "4febc76ecdcdd46fd23c9d5dd6de7f72794ca9f8a3f816ae00deec1a90b5af3c"
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
