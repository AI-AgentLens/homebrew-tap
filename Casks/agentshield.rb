cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2476"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2476/agentshield_0.2.2476_darwin_amd64.tar.gz"
      sha256 "528765ca4f582ef4010bde771e0d42326ce37a5da74e28e16312d7379830af72"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2476/agentshield_0.2.2476_darwin_arm64.tar.gz"
      sha256 "1641a9d6ab96fa67032e1af3bf945e3b0837c60b55988302ef95cb36ef619581"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2476/agentshield_0.2.2476_linux_amd64.tar.gz"
      sha256 "8fb0540958563902b9522de378e000c3331b79faec2756ace2bec8a558d78567"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2476/agentshield_0.2.2476_linux_arm64.tar.gz"
      sha256 "6e03ef849ffef27f857fab47d9b70987d380a37d17dd308beb2f7788590cae8c"
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
