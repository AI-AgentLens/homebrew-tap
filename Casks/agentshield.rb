cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1602"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1602/agentshield_0.2.1602_darwin_amd64.tar.gz"
      sha256 "c2aece578629cd103e87a426e2e7d5810e5a6334097bf7c32822f5db147e4c82"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1602/agentshield_0.2.1602_darwin_arm64.tar.gz"
      sha256 "19ef03c684346c6eadc9124bc86565f2b99eea5aaef3f315014c5f5bdabeb6c7"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1602/agentshield_0.2.1602_linux_amd64.tar.gz"
      sha256 "e9ab5e447aa1c922f830cc5ee8bd7153316dd65a162e4a6994d456a26ad0358b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1602/agentshield_0.2.1602_linux_arm64.tar.gz"
      sha256 "003639d4b9054b0c932d4ca13beb9c8702990b6f97d4fcaa962448fab7842da5"
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
