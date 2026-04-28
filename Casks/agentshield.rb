cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.797"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.797/agentshield_0.2.797_darwin_amd64.tar.gz"
      sha256 "4814fb28c74ac7e6d8cde470609397e3e8d548734d11ed7a1232c8c2ba564c06"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.797/agentshield_0.2.797_darwin_arm64.tar.gz"
      sha256 "75c44e5237d53ecb6f8eed8e7d3604093644261801e6f12e680e776f59d4c113"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.797/agentshield_0.2.797_linux_amd64.tar.gz"
      sha256 "7a07cccd834904b4133b5a08af63fbba331fda725816da2a9f00ba3a2f137fed"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.797/agentshield_0.2.797_linux_arm64.tar.gz"
      sha256 "066789f9a0c25f1de4f28f6ace04028e1aa92f181c199f771fb9958d1c8a5b7b"
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
