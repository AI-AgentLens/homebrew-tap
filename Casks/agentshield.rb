cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1757"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1757/agentshield_0.2.1757_darwin_amd64.tar.gz"
      sha256 "770efdcae32ea3450cd07f332c26ee840bf2d7c388c2025ed2598369899dbfce"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1757/agentshield_0.2.1757_darwin_arm64.tar.gz"
      sha256 "7899fe7e52a88e28b34ee328eec83b7edd8409a8038203d8df12ef9363897bb6"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1757/agentshield_0.2.1757_linux_amd64.tar.gz"
      sha256 "028e7304803ab103d818862092730179714322066bcc848f4670d235f5f9ead7"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1757/agentshield_0.2.1757_linux_arm64.tar.gz"
      sha256 "48b1346c0417ac5bf103cca14f6eb3574faf6b71b42022f49fc50ed3e5b43b57"
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
