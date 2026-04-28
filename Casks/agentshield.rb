cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.800"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.800/agentshield_0.2.800_darwin_amd64.tar.gz"
      sha256 "631adbf5dae1c58907acfe8667a4561c2943332c00e5a84b6a51ace662dda8ea"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.800/agentshield_0.2.800_darwin_arm64.tar.gz"
      sha256 "dedab713c003445b592a24c5f35ca061ff85da213a6d34a257a95b500374b7a2"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.800/agentshield_0.2.800_linux_amd64.tar.gz"
      sha256 "a2a079a1a959034cecd2a9ca97b37eca9b137ecf54a44b4a052a336ee0245eb2"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.800/agentshield_0.2.800_linux_arm64.tar.gz"
      sha256 "a353a9c8f848f03b08a83b0586a84bc0b340b33836336f7563e39c2ef641c00d"
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
