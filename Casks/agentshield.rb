cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2441"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2441/agentshield_0.2.2441_darwin_amd64.tar.gz"
      sha256 "bf4eda6b99adf198f245443d0af9d158c8acdfb52a1ffd6a84243dae0c840d77"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2441/agentshield_0.2.2441_darwin_arm64.tar.gz"
      sha256 "50cd9ac51034314da6173f6c61cf9ee3658366839627de72a9d1b3caa3324bb6"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2441/agentshield_0.2.2441_linux_amd64.tar.gz"
      sha256 "cb12e44c3558483da08b8380d46253cf94806dc42611d21d89274b26b6c704bf"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2441/agentshield_0.2.2441_linux_arm64.tar.gz"
      sha256 "486937e848b8b55620672d58f84d2f6710c51b3f04a1d440d555a8264d967d4a"
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
