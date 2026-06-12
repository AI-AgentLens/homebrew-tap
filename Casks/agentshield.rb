cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1290"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1290/agentshield_0.2.1290_darwin_amd64.tar.gz"
      sha256 "c1f3d13f19fd90eff8f0a07ca878d940600d547f0aac77bd113d45e3050cfbda"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1290/agentshield_0.2.1290_darwin_arm64.tar.gz"
      sha256 "92f564769fd3918645f610df63901bd0a79f5a46de2818938b2e629859a78072"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1290/agentshield_0.2.1290_linux_amd64.tar.gz"
      sha256 "e26182cdb44ecf8691f143bd11860d97dda12b3820377d5bd704fa9a6e7639e8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1290/agentshield_0.2.1290_linux_arm64.tar.gz"
      sha256 "0584c5e93cbf1e9bd917ccde48db2e5ffb8ed76babed48e69b250955d1cda6de"
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
