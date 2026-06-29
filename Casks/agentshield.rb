cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1493"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1493/agentshield_0.2.1493_darwin_amd64.tar.gz"
      sha256 "f3ae2a3a764a2ec490f281f0d53b93ab81270bde21ac513351928e131da47592"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1493/agentshield_0.2.1493_darwin_arm64.tar.gz"
      sha256 "3dd8840760576fa8077d619861e88b4222c6249fd1c66bb4e69445e062f4120d"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1493/agentshield_0.2.1493_linux_amd64.tar.gz"
      sha256 "b52c8edf221081fca99dfa6b0235e300797d64e298ce518b4ed5e581dddb833a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1493/agentshield_0.2.1493_linux_arm64.tar.gz"
      sha256 "df1312162f806fdda5c87469a4cdf33166e01c496077b707c417de6d13b36f46"
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
