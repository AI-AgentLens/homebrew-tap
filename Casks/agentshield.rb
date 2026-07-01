cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1521"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1521/agentshield_0.2.1521_darwin_amd64.tar.gz"
      sha256 "d0cd26652bbe1bce785ee71b21d4e771b809d3487381ae4144ab0e4c5a96bc58"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1521/agentshield_0.2.1521_darwin_arm64.tar.gz"
      sha256 "5afae4e6d7819592840d932c5360b0404ed2c0f607860f23dd5a2483d37cb288"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1521/agentshield_0.2.1521_linux_amd64.tar.gz"
      sha256 "bcd4eecf7310ff6ac52bb1071bc6339f959419a6c8d8166cc6c417436494e90d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1521/agentshield_0.2.1521_linux_arm64.tar.gz"
      sha256 "2143ce54be6c91e24791774f606e486b9fad89b561ebdf6cb776a71e61b59bdf"
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
