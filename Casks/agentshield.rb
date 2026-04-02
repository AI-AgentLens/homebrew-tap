cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.294"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.294/agentshield_0.2.294_darwin_amd64.tar.gz"
      sha256 "44b855e2ae5eda7f200cd0dbc060c088f4fc714cc90feca6eb11b06748f96684"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.294/agentshield_0.2.294_darwin_arm64.tar.gz"
      sha256 "2dd462d2326e0f47eec5805d6a60c58ba84160ea66ddefcf6d01b619b410153c"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.294/agentshield_0.2.294_linux_amd64.tar.gz"
      sha256 "8792ff278ba0d6e2e515dbd576a75c482f82ea3abfb2aff4d2c5d036e8ea32a2"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.294/agentshield_0.2.294_linux_arm64.tar.gz"
      sha256 "0ab3cc51e7ba7ffdc1c0cc4b13d3525e40f971b9b01fb8b4b7bde427406aa127"
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
