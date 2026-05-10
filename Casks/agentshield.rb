cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.934"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.934/agentshield_0.2.934_darwin_amd64.tar.gz"
      sha256 "865fb28812b133fc96169556bf33505c2173922be688240f865780997b4ca2e3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.934/agentshield_0.2.934_darwin_arm64.tar.gz"
      sha256 "8de8e8403a8f78666ef968b64bbdbb876ac3ff20b150813a99ac89f313d82ee9"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.934/agentshield_0.2.934_linux_amd64.tar.gz"
      sha256 "1c9cf8e804ad64cb773d7ccb1f77506a455db183963a16571dd345b7e18c42c7"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.934/agentshield_0.2.934_linux_arm64.tar.gz"
      sha256 "b4b6d793bd2a95029901b84bb93570d90b63fdcb50e80c6576c722a22e1c499b"
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
