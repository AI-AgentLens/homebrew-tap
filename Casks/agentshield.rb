cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2480"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2480/agentshield_0.2.2480_darwin_amd64.tar.gz"
      sha256 "feae38d580eee3321351c869e4fa5e00d8839fbc36c3834d7ccd524d9ca1aef5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2480/agentshield_0.2.2480_darwin_arm64.tar.gz"
      sha256 "2b824220fa36bf44407af260c93960f4faad30dfe5d0bd9704e5c94e96eef8ee"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2480/agentshield_0.2.2480_linux_amd64.tar.gz"
      sha256 "283277fd87798db5dde337b1a5ea8473d1c17f60804aaa2e303c95cfbc593d4e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2480/agentshield_0.2.2480_linux_arm64.tar.gz"
      sha256 "6a16e1f0b6552877712f8e8e47b781a7cf174cc7a933ffee2cedbdcd24ae85df"
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
