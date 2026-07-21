cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1701"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1701/agentshield_0.2.1701_darwin_amd64.tar.gz"
      sha256 "e6bd5689f10b104990f613b44e8ba0a6ce6ae9d569628eb91b2903311f514d54"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1701/agentshield_0.2.1701_darwin_arm64.tar.gz"
      sha256 "9289852b14063c65f9c4f01edb2b5a0880836cac7558d8b35dbc8dc7e214df57"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1701/agentshield_0.2.1701_linux_amd64.tar.gz"
      sha256 "1351dae236ba4e6d3f9bb78e9280aa6ac691b984524e53a8baf41b4daa6a55eb"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1701/agentshield_0.2.1701_linux_arm64.tar.gz"
      sha256 "7167ed0ee221803fd68ec419d1b4c7abbaf1914aa79f243187cb4f4a2e7ae5f1"
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
