cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.303"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.303/agentshield_0.2.303_darwin_amd64.tar.gz"
      sha256 "3cb6f94c39c727571454632368451f4acfae6daef72b290b66f082b178fec101"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.303/agentshield_0.2.303_darwin_arm64.tar.gz"
      sha256 "3c6fa07f220f636f537324f58430638e3056ecbf76bce7b31d1388bc3f2e58e0"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.303/agentshield_0.2.303_linux_amd64.tar.gz"
      sha256 "68a7a559461e28fa0a1c3f486a3723a67f99db0d1d071de847a41d1460eeae59"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.303/agentshield_0.2.303_linux_arm64.tar.gz"
      sha256 "6bbbc3086950b32cd9fc2a039039cf6a5bf22bf2ca1ca43a9dc963acc1664823"
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
