cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.671"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.671/agentshield_0.2.671_darwin_amd64.tar.gz"
      sha256 "222a6e92d6d3388d6346bb1c4fc279a81531b239ede22a4eee761d4a8410dd93"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.671/agentshield_0.2.671_darwin_arm64.tar.gz"
      sha256 "e60c4b2133c224e4f392a0c91ff343d336f409a28b6637b899562c98c87c2b30"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.671/agentshield_0.2.671_linux_amd64.tar.gz"
      sha256 "eb7808861976d6a5d690fc3ab8fc529a0b6fcc53bf5f94bb6b6f807e1dbee7e5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.671/agentshield_0.2.671_linux_arm64.tar.gz"
      sha256 "2f5d964d4a0123f4ab91b7eb6f6ad697b971a32cabe4821723d9e00baba7cd67"
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
