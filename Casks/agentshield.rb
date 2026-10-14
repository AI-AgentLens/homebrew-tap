cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2425"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2425/agentshield_0.2.2425_darwin_amd64.tar.gz"
      sha256 "164d4911942ec371e8dac8ee56bbc8c571e2fdadf9bdcbd4a4e7cfb5e7a22332"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2425/agentshield_0.2.2425_darwin_arm64.tar.gz"
      sha256 "d65088ceaf0fec65e78fb43a350da0ad52c00ea1ba406b47b7716fa5026c7e72"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2425/agentshield_0.2.2425_linux_amd64.tar.gz"
      sha256 "f6130926decab182bc5eb30b806f412c8d180a4380a7542c92398087158c897a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2425/agentshield_0.2.2425_linux_arm64.tar.gz"
      sha256 "2cadc9003b903e150a1780a1286c9106a4e4ba860efb1cfa2aae381bec70ff9c"
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
