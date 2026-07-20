cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1694"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1694/agentshield_0.2.1694_darwin_amd64.tar.gz"
      sha256 "528d6461e3ff48ad7d1e66af84a3ad272a793060061a777b0590a6c49c94a2c0"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1694/agentshield_0.2.1694_darwin_arm64.tar.gz"
      sha256 "db502b37aad4295a208a257bcd10d486c86c7941d8240270b9f11ec44b275abc"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1694/agentshield_0.2.1694_linux_amd64.tar.gz"
      sha256 "e756ccb50bef843fcda4da70755384d2f00ef949897f21d1440ee4eb9c3e17db"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1694/agentshield_0.2.1694_linux_arm64.tar.gz"
      sha256 "8164070087d3ef1b11d9dbe2c94de3770105b4d9eb10f7578ac71d5fe85e52af"
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
