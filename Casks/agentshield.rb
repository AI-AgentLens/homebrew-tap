cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.979"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.979/agentshield_0.2.979_darwin_amd64.tar.gz"
      sha256 "3faabe04309ef58f61532bdb60c5ed671cce97589a1c284e397fd3275083a19f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.979/agentshield_0.2.979_darwin_arm64.tar.gz"
      sha256 "574c3618c93ddeeedea43cf2e5991837da5b357181833011a11dd13dbc94492c"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.979/agentshield_0.2.979_linux_amd64.tar.gz"
      sha256 "f894c82a8cf724fe54e594fa797e157f2e6d26dde0c0a5cc41793daf0c55d4e1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.979/agentshield_0.2.979_linux_arm64.tar.gz"
      sha256 "976997698521b7e0237003581eef02b11830f9a5ef6742040b47714898600fb7"
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
