cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2361"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2361/agentshield_0.2.2361_darwin_amd64.tar.gz"
      sha256 "37dbe079dbc90d2c6857d1a671e9015b8a40aa506df562ce33184a5a30ba23ff"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2361/agentshield_0.2.2361_darwin_arm64.tar.gz"
      sha256 "17c4de99921105af5b9e9bfc50a38fb5bf614956a291a66b347e6e027c7dcc50"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2361/agentshield_0.2.2361_linux_amd64.tar.gz"
      sha256 "c3559284c5698230d4e4aeffd312c3ce63f3472af52a70444cbc02aad4e38354"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2361/agentshield_0.2.2361_linux_arm64.tar.gz"
      sha256 "2e8066f5b723904a75ce3116de3c0f330e154b7cf4a60be1af2e4e1c2a80e94e"
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
