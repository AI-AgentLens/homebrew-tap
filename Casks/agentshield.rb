cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1763"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1763/agentshield_0.2.1763_darwin_amd64.tar.gz"
      sha256 "f4c6dcf2014527bd7c590195caa77df903ffe54b769d9c7dcdd77419e9535836"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1763/agentshield_0.2.1763_darwin_arm64.tar.gz"
      sha256 "15cc8f02a827946ff05b2063386768951e54818ff7cc1308e04d32307706ec8f"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1763/agentshield_0.2.1763_linux_amd64.tar.gz"
      sha256 "56ade25e1ef099f537f5e4d64795ec7e822408e747b11b371e972f7282da988c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1763/agentshield_0.2.1763_linux_arm64.tar.gz"
      sha256 "d4b7d85a9fdffd8ca0c77953a996e5491db7b20453eebd35f413627179e95909"
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
