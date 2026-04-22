cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.689"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.689/agentshield_0.2.689_darwin_amd64.tar.gz"
      sha256 "3fe50324c86d31e11a772e536a04dbe32df58f581d5bd2f21c6ec72149ac1572"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.689/agentshield_0.2.689_darwin_arm64.tar.gz"
      sha256 "30be6261912f86ac89b27596f71a05b6543284670588247af37acd42848c99f6"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.689/agentshield_0.2.689_linux_amd64.tar.gz"
      sha256 "2d81bd112653b411a2ee8dc2a4e879ca53518ae95ad900432bd4d19237e8d2c8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.689/agentshield_0.2.689_linux_arm64.tar.gz"
      sha256 "ddb7659114a567012bd0234d48539fc3bda50eb83fc3d286c735c7c933220044"
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
