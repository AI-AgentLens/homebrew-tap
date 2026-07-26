cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1733"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1733/agentshield_0.2.1733_darwin_amd64.tar.gz"
      sha256 "1dba47a6e9ba92d17b42d4badf23d48821d2f6014875bf54b239ebdb00cc8955"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1733/agentshield_0.2.1733_darwin_arm64.tar.gz"
      sha256 "04d9be55a58cd917972ade8c2a8a92be0d4009baef94d0c735128eb98d0ad63e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1733/agentshield_0.2.1733_linux_amd64.tar.gz"
      sha256 "446917593afdf6d3da73544043883ccc8180c2ca315ab7115d4ab7f8620e9831"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1733/agentshield_0.2.1733_linux_arm64.tar.gz"
      sha256 "84e78d4ac25b615d0250ddf1462a578a16abcc1a792fb36a8d585e02882679b9"
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
