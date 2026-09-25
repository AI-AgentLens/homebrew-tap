cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2260"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2260/agentshield_0.2.2260_darwin_amd64.tar.gz"
      sha256 "51f2bdc1cf4d5d90d66ea7ae032f156ab5d10906850eab761207e9fc9b1eb9c5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2260/agentshield_0.2.2260_darwin_arm64.tar.gz"
      sha256 "998928e30af8cc09b491a563a9ad8ba1895e823674723e4b3061f19953dee04b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2260/agentshield_0.2.2260_linux_amd64.tar.gz"
      sha256 "8ede1cfe56f03447543eac8d97dd877e2982672ff660da2c37f21a5cc02b7f24"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2260/agentshield_0.2.2260_linux_arm64.tar.gz"
      sha256 "e45ddbffa418ca7ad074486c2abd7442ae25a6fdf8c6911a3e7bd49aa4a07f10"
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
