cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1976"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1976/agentshield_0.2.1976_darwin_amd64.tar.gz"
      sha256 "d418ae281ed9642ce8f81e61a32c9ada9bb5078c22263507d0406805a7d6ba68"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1976/agentshield_0.2.1976_darwin_arm64.tar.gz"
      sha256 "42effaed46d7a891193ba50e7db6834d8e422c25699a2bcbb53d014bda082021"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1976/agentshield_0.2.1976_linux_amd64.tar.gz"
      sha256 "274439b10c7ec635dd968e13c9720ab654d387db87951a95982bb2dae91c9d41"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1976/agentshield_0.2.1976_linux_arm64.tar.gz"
      sha256 "202861be916d24cdd62ce896568fbd84fade4256ba72ee99caa13d5437d8fbdf"
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
