cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.574"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.574/agentshield_0.2.574_darwin_amd64.tar.gz"
      sha256 "1efa17183f32c87d9d2c38a3f330945a1dfb79e60ef820fded3ad6e890bc14fd"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.574/agentshield_0.2.574_darwin_arm64.tar.gz"
      sha256 "0762ef30fadf09c60c1fd967fc9c98bdcd7e725d804393fb0a8f9b2f1391b47c"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.574/agentshield_0.2.574_linux_amd64.tar.gz"
      sha256 "ff999f1cbdaf6a4e7d99b023a1880159878557b8193bd8445708d823879117eb"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.574/agentshield_0.2.574_linux_arm64.tar.gz"
      sha256 "d8f0fc4e36c19442c5d9acf7ed08d0064ec4d4bfb921b672c82841f75f375a4b"
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
