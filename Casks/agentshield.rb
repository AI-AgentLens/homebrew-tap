cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1108"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1108/agentshield_0.2.1108_darwin_amd64.tar.gz"
      sha256 "2efebfc053628c8d1408aec4dc87d7a2eb2b4a47e38b1401425f2f228e9b9950"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1108/agentshield_0.2.1108_darwin_arm64.tar.gz"
      sha256 "57b99c8b0a73ba51ae0f3383ff51c3b1008783223de7ca7ce9ef63d0c3a9c59f"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1108/agentshield_0.2.1108_linux_amd64.tar.gz"
      sha256 "9de6dd671a6795707002f5105e0730382a17e81fe4bad4fff1411decfc133c9f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1108/agentshield_0.2.1108_linux_arm64.tar.gz"
      sha256 "e6e56eb79a83009eaebda14744fcdde3e3473f8c2e78a5dff5a70b1c707d65a6"
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
