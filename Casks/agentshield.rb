cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.660"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.660/agentshield_0.2.660_darwin_amd64.tar.gz"
      sha256 "eb161f5379d8f284a2d7064d4a4088e73586ef599a98ec2972241ffe92f6dbcb"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.660/agentshield_0.2.660_darwin_arm64.tar.gz"
      sha256 "bc6f62669adb25d4b16f3c4c65fcddae0dd5afa3540b6e8c97dc56ad43221085"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.660/agentshield_0.2.660_linux_amd64.tar.gz"
      sha256 "28e9f1734b1e99e5359726be7d7523f7b54ef89a2e1f8274eb246231cbc4d9f9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.660/agentshield_0.2.660_linux_arm64.tar.gz"
      sha256 "93915c7ddb801df743e0cbbf92e341c61e9b626b550be20c8dcc47f49f88a2c9"
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
