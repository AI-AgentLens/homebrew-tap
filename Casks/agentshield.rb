cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.118"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.118/agentshield_0.2.118_darwin_amd64.tar.gz"
      sha256 "042989d682bdf46ca5be181dfa530ed0ed1aac371607bd31fba5746c6c53eb29"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.118/agentshield_0.2.118_darwin_arm64.tar.gz"
      sha256 "56c97c765784112dc2791867da7da066dcce82a829a0faaa79e9f0348e73bc38"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.118/agentshield_0.2.118_linux_amd64.tar.gz"
      sha256 "318e1bf9cab5856589c0f57456046dc1a98f8c450dd18f900ee0938698f78788"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.118/agentshield_0.2.118_linux_arm64.tar.gz"
      sha256 "873f0f8453010c81d3de4dde4a8a88c4b2f980842fa5880317de0d2b3139b53b"
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
