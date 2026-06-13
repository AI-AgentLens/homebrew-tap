cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1300"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1300/agentshield_0.2.1300_darwin_amd64.tar.gz"
      sha256 "2b160e997fa34b9c2de5104817a22c3e6d9f20513c4ee1dfc61153f18c2f96fe"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1300/agentshield_0.2.1300_darwin_arm64.tar.gz"
      sha256 "5463b4f71808034bdbdb5ffe892354aa3224e2c032d3ebc56d2c5a247c153fea"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1300/agentshield_0.2.1300_linux_amd64.tar.gz"
      sha256 "13ee717e7f785a51abc11eca5543cebe9e8150d95ef93a36242c202afe8b7cc0"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1300/agentshield_0.2.1300_linux_arm64.tar.gz"
      sha256 "931a49d85c5b5e570fd3208d20b8e8623b7dc13109c55960ace2e4b09de98f79"
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
