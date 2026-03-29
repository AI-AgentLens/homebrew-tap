cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.200"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.200/agentshield_0.2.200_darwin_amd64.tar.gz"
      sha256 "5f9c2cd2cf93c70d7316d6d2d2ca2a9977471b6ae5caac6a294debf5280c5cd6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.200/agentshield_0.2.200_darwin_arm64.tar.gz"
      sha256 "3ee67cc496908f1d90c349e0d0768310264d7a39e2d0376405636fb42ecf74d3"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.200/agentshield_0.2.200_linux_amd64.tar.gz"
      sha256 "915013f15f22cb5007c65fdb41806a7719dc4383db945131a405318afa381a76"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.200/agentshield_0.2.200_linux_arm64.tar.gz"
      sha256 "96f1080aa4a7d8a2819a6676d135564449e488f04894840d26040262aee3a0de"
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
