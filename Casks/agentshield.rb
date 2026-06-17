cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1346"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1346/agentshield_0.2.1346_darwin_amd64.tar.gz"
      sha256 "ed1684d1b079ab792c5ad2fc5ec967a4bccc569de1fbf057355fe1d039364012"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1346/agentshield_0.2.1346_darwin_arm64.tar.gz"
      sha256 "fcd3080cf23a0a5783c62085bb768b9e17b3be0819cd26c1b6954ac77c3be128"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1346/agentshield_0.2.1346_linux_amd64.tar.gz"
      sha256 "82d067cc341f264015ef0a5b1c6799b5728fcd57043ada7e14f26e4a1fd9e79e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1346/agentshield_0.2.1346_linux_arm64.tar.gz"
      sha256 "79276a60fa2e9a32af898011da6368b4a7b01831d832347265cd57fbf185a885"
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
