cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1765"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1765/agentshield_0.2.1765_darwin_amd64.tar.gz"
      sha256 "75b7581ac8ef857754d9809ed1d2dfce27162c512f412a16e2a071b615a8adc2"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1765/agentshield_0.2.1765_darwin_arm64.tar.gz"
      sha256 "3655d1b0cbd7d4f1c1aa0906cd9eb3e3dfedd8779ca23878ffec1fe04a4cd753"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1765/agentshield_0.2.1765_linux_amd64.tar.gz"
      sha256 "b1de07d1d0d506337cae9369fca525392dc7f5cb45949996649177c6a2f61ff1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1765/agentshield_0.2.1765_linux_arm64.tar.gz"
      sha256 "30b8c352afb668ecdbcc4aca2b4a006d82d1a0abb6e8a79bbd8623e54909d3de"
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
