cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1667"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1667/agentshield_0.2.1667_darwin_amd64.tar.gz"
      sha256 "3b2e0940732eb9f2516e74a2ed43cc9f476d2a8a85a83c1364fed31c62fd7cb7"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1667/agentshield_0.2.1667_darwin_arm64.tar.gz"
      sha256 "d7654bde28cd391f83da08ac9420789dad77dc01e3877c4a752a8f1a15b99af3"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1667/agentshield_0.2.1667_linux_amd64.tar.gz"
      sha256 "4072dcf1e0d9ab72e55ae56d48e8824d8e977773d88490f41a33aa5ec5767682"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1667/agentshield_0.2.1667_linux_arm64.tar.gz"
      sha256 "b0d707b655e0bcd83a3356989de6153c43d39d24ebff19fddd409812d33f767f"
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
