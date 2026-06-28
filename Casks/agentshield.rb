cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1475"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1475/agentshield_0.2.1475_darwin_amd64.tar.gz"
      sha256 "ca5abfbe648e82a0dca296a53a0f6fc7a0ff5a8574430216a6910486e65514a5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1475/agentshield_0.2.1475_darwin_arm64.tar.gz"
      sha256 "e18a9a5d2f7e9ffaccfa66950ae7585b05f2f32f4b7b6bf8ea531e3864b8a1d2"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1475/agentshield_0.2.1475_linux_amd64.tar.gz"
      sha256 "beceaca645abe7eb345953060fc89fa4da2c333c749d3284db277955283f0625"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1475/agentshield_0.2.1475_linux_arm64.tar.gz"
      sha256 "6142fe48cdbaad4d0a999cefe5acc0da0864488c4845e4928f142403726ef9b0"
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
