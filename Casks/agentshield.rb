cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2297"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2297/agentshield_0.2.2297_darwin_amd64.tar.gz"
      sha256 "16b9aed07aa3f975d69a9a66168f95d1a2738657fec5e276230e543101591c3c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2297/agentshield_0.2.2297_darwin_arm64.tar.gz"
      sha256 "9887df781ecca2f1a8cfb21b4c71f9a1b26765934a5a26da6e91afa4c4282878"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2297/agentshield_0.2.2297_linux_amd64.tar.gz"
      sha256 "f777aaf3746356984fa703896fb1d33a0c2b0949de7c6b5b7d6634c9ce1eb136"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2297/agentshield_0.2.2297_linux_arm64.tar.gz"
      sha256 "f27e4b7f9242bcaa4679b2a67368aa5902200ea2ec2fa994d9392deec39400d1"
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
