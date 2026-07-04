cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1547"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1547/agentshield_0.2.1547_darwin_amd64.tar.gz"
      sha256 "92ad73ee72f9021a739480a7c2bd801069ad764a3e178d988f2be30424f80984"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1547/agentshield_0.2.1547_darwin_arm64.tar.gz"
      sha256 "ed0092e3d52a5f7107e4847a5797a548ca022b05eb43666a7d5779df45301732"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1547/agentshield_0.2.1547_linux_amd64.tar.gz"
      sha256 "41d4ebd74db14d4b2a24c29340f93908631f058b7b675b60ae823e750d85db46"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1547/agentshield_0.2.1547_linux_arm64.tar.gz"
      sha256 "eaf8a83b6f9fa09e31eb983425f43c1b4f1f3dcd49aad5a6615d2c0c43f1f895"
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
