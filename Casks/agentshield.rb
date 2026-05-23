cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1101"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1101/agentshield_0.2.1101_darwin_amd64.tar.gz"
      sha256 "7b68fc553bb29de419095e56d99cff4ee64b5815f47448a1b30b015673b4631e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1101/agentshield_0.2.1101_darwin_arm64.tar.gz"
      sha256 "1b87884c1ea4ea5b5af201482d64d280cc0a0f086efc6ff1385fc87352acfae6"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1101/agentshield_0.2.1101_linux_amd64.tar.gz"
      sha256 "37c21ed4ff68b1d6364f6c5d4d7a5f9ffbf480dcc4579fbe6706b1f59b337484"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1101/agentshield_0.2.1101_linux_arm64.tar.gz"
      sha256 "809400b16873c6480473c3dc1351d748065937dd5b1549bbf41f8077f2ae7346"
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
