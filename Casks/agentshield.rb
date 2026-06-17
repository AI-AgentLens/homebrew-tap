cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1347"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1347/agentshield_0.2.1347_darwin_amd64.tar.gz"
      sha256 "e940940311fe15ddc188874312bb92f92c8de04fd1bbf7a77476526101413419"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1347/agentshield_0.2.1347_darwin_arm64.tar.gz"
      sha256 "9d66b9f7f9ee71bf5528c12e5a338dfed77048e7181e2a7a3a184ccc5baa40e2"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1347/agentshield_0.2.1347_linux_amd64.tar.gz"
      sha256 "2116464a9157927211cbeef7d6ece5767735d62886b9aad9c1e55ddc17254edb"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1347/agentshield_0.2.1347_linux_arm64.tar.gz"
      sha256 "eb3f7a69db50e0bd42d2b34711b50a5043729be1d31ffce8bfc7c25aa741029a"
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
