cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1447"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1447/agentshield_0.2.1447_darwin_amd64.tar.gz"
      sha256 "415cfed86486b76fb9362d850f20eb6dffeaa57e478efe338df76ea934844a6a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1447/agentshield_0.2.1447_darwin_arm64.tar.gz"
      sha256 "b1569f7cda73e0250ee01d773afc391a3dd2337805b3cba872e8d899848ccb1b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1447/agentshield_0.2.1447_linux_amd64.tar.gz"
      sha256 "a1c844f623f3c7096862d12c8d46bafb876612f3de21ec56c2da4b0e3e96b1c4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1447/agentshield_0.2.1447_linux_arm64.tar.gz"
      sha256 "dc68339672982fdbceec81193d3ec321ef48132788a4ca153860b34b748e7134"
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
