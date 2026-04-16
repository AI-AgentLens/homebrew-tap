cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.605"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.605/agentshield_0.2.605_darwin_amd64.tar.gz"
      sha256 "e32df44ce347eebde9b53100c5add8380fc64eed72d232bac6e89d798d2a86ae"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.605/agentshield_0.2.605_darwin_arm64.tar.gz"
      sha256 "da40e3c9d330e4aad83d1b069e62a721aa319bd4baa0bc8529e6f7d6b0354a16"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.605/agentshield_0.2.605_linux_amd64.tar.gz"
      sha256 "53f75aa34b1377310eaeaf7506410f6fa3298fcb25a66ed7ccb96f176a062f02"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.605/agentshield_0.2.605_linux_arm64.tar.gz"
      sha256 "8f45f1e6f76adeb8106e8da7a9e933f883cb10fa7e3a944fbedb008a380d9188"
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
