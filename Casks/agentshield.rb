cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1820"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1820/agentshield_0.2.1820_darwin_amd64.tar.gz"
      sha256 "a5965afd270e584713f2659030940baf2cffaca1101c37417548774b324b7de0"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1820/agentshield_0.2.1820_darwin_arm64.tar.gz"
      sha256 "138fd32aa4c12ce43be1c66ad6427e33b89dc48b9478c69538304a62489e0af5"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1820/agentshield_0.2.1820_linux_amd64.tar.gz"
      sha256 "7a02683338efd887353f1faf47e79a68264e3a5cf3fb3e9a1fb5f0ef89eafd3b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1820/agentshield_0.2.1820_linux_arm64.tar.gz"
      sha256 "13745876e6cde43f15b4b398a5fa34bb92b61d59f824aef7b915a2eb32df42cf"
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
