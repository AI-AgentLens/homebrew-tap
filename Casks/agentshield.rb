cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1396"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1396/agentshield_0.2.1396_darwin_amd64.tar.gz"
      sha256 "3a25cfd11c15faab0507365c8ce748110400b9b20caa82a2a62921a0e5c86d5d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1396/agentshield_0.2.1396_darwin_arm64.tar.gz"
      sha256 "007d25a19318937571567c2e3c4d4e89561dfc18362adc48b5288d3ad15dd03e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1396/agentshield_0.2.1396_linux_amd64.tar.gz"
      sha256 "347a84636df42d66465b0ccbe7980250f1c94a2aeedd3f20c4f516525ec11944"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1396/agentshield_0.2.1396_linux_arm64.tar.gz"
      sha256 "4cd29149ee1e57abb16705502f80612d95df9253abec738cb67465f079503e34"
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
