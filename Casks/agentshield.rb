cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.995"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.995/agentshield_0.2.995_darwin_amd64.tar.gz"
      sha256 "da5c5de161ac0a528334c886ca13d9871ce80951c058a4d4e5b00a2b171f002b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.995/agentshield_0.2.995_darwin_arm64.tar.gz"
      sha256 "066c52c2da35ae9c21b9ff8c9bbdb61079547d62dc43d1b438913e90bdc0d09c"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.995/agentshield_0.2.995_linux_amd64.tar.gz"
      sha256 "a4fef2696a479b64df2d725d8694b84d2d082debc44d2733160d94cbea3dac02"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.995/agentshield_0.2.995_linux_arm64.tar.gz"
      sha256 "0284d1451b7fd18bf6ff8fe130c1d4f48e5d33b55264a53d34a498f7d519d391"
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
