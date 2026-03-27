cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.104"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.104/agentshield_0.2.104_darwin_amd64.tar.gz"
      sha256 "6b20033ed7410204150fcada4a536b58e66f6babfcc446cf7dc1c78bfbd0e94f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.104/agentshield_0.2.104_darwin_arm64.tar.gz"
      sha256 "90fd069fa9f23c4dd2956cbc802124df568be90e4f6b52039f96069d6c83926b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.104/agentshield_0.2.104_linux_amd64.tar.gz"
      sha256 "ba0ea56792f2ebd918d2c3320a1e665020817982b4be9ee8007d0319c83ee166"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.104/agentshield_0.2.104_linux_arm64.tar.gz"
      sha256 "41f3ba99bcd78c62ad8c657d03af5eff028f4eac8d57b61ecc06ff1fc5ff3444"
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
