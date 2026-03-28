cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.144"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.144/agentshield_0.2.144_darwin_amd64.tar.gz"
      sha256 "081d149b3b989158f15cf0418dd663b0207f77480176de910a22f397f968933e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.144/agentshield_0.2.144_darwin_arm64.tar.gz"
      sha256 "43e3732c076848df6567901c4f93d3f0a27eece9910d4a4797a0b0736113922d"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.144/agentshield_0.2.144_linux_amd64.tar.gz"
      sha256 "daeb33c53d9a38fc7934d3b22b908fe978f0eda8afcafb190ef62596ccde788b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.144/agentshield_0.2.144_linux_arm64.tar.gz"
      sha256 "2bf81a6f4dcee42855a0eefd538ed60084934ef2d059db437c2a9b617f83066b"
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
