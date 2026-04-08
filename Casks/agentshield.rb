cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.485"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.485/agentshield_0.2.485_darwin_amd64.tar.gz"
      sha256 "4e659f618177334bde27f741be85ff55bbc5da011cca16df02758385a9e1e147"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.485/agentshield_0.2.485_darwin_arm64.tar.gz"
      sha256 "6ac358ea594008a6986bc55f3db3cbf018df09c3ad03b2d3486d4265f3a5ed04"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.485/agentshield_0.2.485_linux_amd64.tar.gz"
      sha256 "b4ec45ff1d509d4151c10d280781930e79000f27005c27d43fe3ab0998952fcd"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.485/agentshield_0.2.485_linux_arm64.tar.gz"
      sha256 "ea791f072518ef3f497eb54c405eb239c53499491e73beadbbc0c54c225b4b8c"
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
