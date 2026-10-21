cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2495"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2495/agentshield_0.2.2495_darwin_amd64.tar.gz"
      sha256 "ff89ef89775f0f7416d8bc9a9fd8ee14c76ae348f792c114068bfbf173facd25"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2495/agentshield_0.2.2495_darwin_arm64.tar.gz"
      sha256 "d20beb1d822c5ae78a1fccfcddd69165088836e95ceb5c727c456735dc3c7ccd"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2495/agentshield_0.2.2495_linux_amd64.tar.gz"
      sha256 "3874e773f47cf2e2ecb2489c07f67a70cc0ba1807dc3a43febe2e068c4ff551c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2495/agentshield_0.2.2495_linux_arm64.tar.gz"
      sha256 "14d35e4b79e1cc95a8b221e6a1f1a5b6195b9ea65cc3731134d53f49d47aa608"
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
