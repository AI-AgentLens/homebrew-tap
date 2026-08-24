cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1949"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1949/agentshield_0.2.1949_darwin_amd64.tar.gz"
      sha256 "742c0e4788afc6bff97272edd0adcc5015b7848d7f993cbf70657130ec40fda9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1949/agentshield_0.2.1949_darwin_arm64.tar.gz"
      sha256 "bf17c4b42ca205944467299237383997cac95eb390cfad94700d648c63cf9a59"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1949/agentshield_0.2.1949_linux_amd64.tar.gz"
      sha256 "839043d25eafba96dca9b0077dd33c736bc0c8fa4499ede00e00a2576f0083d6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1949/agentshield_0.2.1949_linux_arm64.tar.gz"
      sha256 "7cdaed74aa4348478eaa88035f1d4c95060f3953581943f92ee34548d2ca93d4"
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
