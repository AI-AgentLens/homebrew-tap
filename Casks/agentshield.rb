cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1430"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1430/agentshield_0.2.1430_darwin_amd64.tar.gz"
      sha256 "108b52809555cd81ac9a6d7119d2990db331cb48d708067a37a686df498663ff"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1430/agentshield_0.2.1430_darwin_arm64.tar.gz"
      sha256 "5e61729272e38396d519be1b89cad1010ff6e7d7e88687041c51ed50f8f4f27c"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1430/agentshield_0.2.1430_linux_amd64.tar.gz"
      sha256 "8317526aa2bbf73f38812d71227b994442f2c8464a427f592b97994e266f84d4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1430/agentshield_0.2.1430_linux_arm64.tar.gz"
      sha256 "e37599f9d45e0976e9cd7ef471504cf048c4dc38c6bdd2bca6e687fc09e919c8"
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
