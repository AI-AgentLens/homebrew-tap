cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1046"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1046/agentshield_0.2.1046_darwin_amd64.tar.gz"
      sha256 "63046cb1d614b2fb62a24ebf0b3507de3e8cb35f2d1bd6e276eddc1ac9fc3082"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1046/agentshield_0.2.1046_darwin_arm64.tar.gz"
      sha256 "308c8ec7326f326fba9a6fa4bbe7cda9f444b24b900f431d3f836a26743053ad"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1046/agentshield_0.2.1046_linux_amd64.tar.gz"
      sha256 "42d873b4f4b796811b933d07d14a5e082755602538152725598d9aa524642be1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1046/agentshield_0.2.1046_linux_arm64.tar.gz"
      sha256 "269af6e141c87e4ca5ae83348cf379b72b2ee653129eb58fff45bc60ab332d27"
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
