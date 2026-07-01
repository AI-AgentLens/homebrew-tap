cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1507"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1507/agentshield_0.2.1507_darwin_amd64.tar.gz"
      sha256 "d07b1c48a3e1c419384a18dbc87cdb26f78302fff561528b53d400b00e632960"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1507/agentshield_0.2.1507_darwin_arm64.tar.gz"
      sha256 "1c8f7b7783a9bbc17f8f0aafaa7a37ea7bfd773f1a6cf4a02119e7b7c707fcc9"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1507/agentshield_0.2.1507_linux_amd64.tar.gz"
      sha256 "29f82a304c29b54fcb71bfcd07a8b169dea239b23df585210f467683e44059e9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1507/agentshield_0.2.1507_linux_arm64.tar.gz"
      sha256 "640ca5f02876a224527cb95c28eae488589cb845390eafd7352fd0376e652c95"
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
