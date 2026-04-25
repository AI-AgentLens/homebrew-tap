cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.730"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.730/agentshield_0.2.730_darwin_amd64.tar.gz"
      sha256 "39f0a9add72407e9a616c27b87f1c44e560ab8141c03134d69a0f6a671614fbf"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.730/agentshield_0.2.730_darwin_arm64.tar.gz"
      sha256 "c997bbff73c104fced582b31831cab69bde17c332ffb584736f048527ba56242"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.730/agentshield_0.2.730_linux_amd64.tar.gz"
      sha256 "f4cb0b4253589b9d006b5e31a3f7cb6e3ca861298b320edbd6bfcc4a55043907"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.730/agentshield_0.2.730_linux_arm64.tar.gz"
      sha256 "a70c413db02589c93cbd377b56cdf69c24845cedc63dbc7a2ba61d0c110a8fa9"
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
