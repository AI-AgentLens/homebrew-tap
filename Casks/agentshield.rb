cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1730"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1730/agentshield_0.2.1730_darwin_amd64.tar.gz"
      sha256 "8052dc647fe7ada9632502a3434f006bf6b12aac655d4225ee2e239e6e19fd9c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1730/agentshield_0.2.1730_darwin_arm64.tar.gz"
      sha256 "2b0aa8465754c9a19d037bdf45bfc5a2da70a91b218473fb54be24562cfdf84b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1730/agentshield_0.2.1730_linux_amd64.tar.gz"
      sha256 "544c8c31bc30391d32da22f2b9bf2be2c932d3dd27ebb151c4698cde7a10b2aa"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1730/agentshield_0.2.1730_linux_arm64.tar.gz"
      sha256 "235c5b21acc1f89b45a57cf61d1605687bbec7a694fd36b758e08c4416273a23"
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
