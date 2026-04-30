cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.833"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.833/agentshield_0.2.833_darwin_amd64.tar.gz"
      sha256 "d7110a4bf5dae5f167f57893d3e9c296ddb07ac038b5949200bd740f9c70e85f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.833/agentshield_0.2.833_darwin_arm64.tar.gz"
      sha256 "8e6d9ec563375bd97058583e0bbbb888c1dff2c26cfb06a17a6527f778fe2c46"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.833/agentshield_0.2.833_linux_amd64.tar.gz"
      sha256 "c119b0b0cf34619c9fce319941fddf5d66875a7515a8aca2e29686fd5213c267"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.833/agentshield_0.2.833_linux_arm64.tar.gz"
      sha256 "b6d62691f9644da1570aa0d173d03de7e41286165c2535cf5ca2915f5571d55c"
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
