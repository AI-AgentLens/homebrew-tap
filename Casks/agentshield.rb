cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1381"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1381/agentshield_0.2.1381_darwin_amd64.tar.gz"
      sha256 "d96e288dd24d76d5ed076a6d6564209a2181a0e3d141384549f3bc1d3dded9c2"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1381/agentshield_0.2.1381_darwin_arm64.tar.gz"
      sha256 "388fb3ba457e4809b1f91d203997ed7baa8425e8447814e0c3da12dbcefd768e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1381/agentshield_0.2.1381_linux_amd64.tar.gz"
      sha256 "73b312ad055c50f13559eb5d60136f554a0d04fae76dce97306a989b315bda2f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1381/agentshield_0.2.1381_linux_arm64.tar.gz"
      sha256 "e349b1c20ad2c439d0db0cd278c2a879422b03d330e66dfde8ea716e1358bbb8"
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
