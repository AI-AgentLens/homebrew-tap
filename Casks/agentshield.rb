cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.112"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.112/agentshield_0.2.112_darwin_amd64.tar.gz"
      sha256 "238861616699553e16a1f26f880f36e9874c540552b55d37c1824e6c7483273c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.112/agentshield_0.2.112_darwin_arm64.tar.gz"
      sha256 "9f0033aa1906050483d49aafca7ac195c306191cb09732a3e6ffeca392023534"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.112/agentshield_0.2.112_linux_amd64.tar.gz"
      sha256 "6e4b5000ed891437ef246ca87214be7e070257ace600c037b8c16fa224be947c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.112/agentshield_0.2.112_linux_arm64.tar.gz"
      sha256 "eebf28f58aeee6e43403e196f0382f1ef91d8d562ee09e8e40921ee25c80516c"
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
