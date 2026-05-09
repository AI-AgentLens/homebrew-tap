cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.924"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.924/agentshield_0.2.924_darwin_amd64.tar.gz"
      sha256 "d1bdc0cd553657562c64fa0612811cf6da731c707be557ff27ec96912cb0bd45"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.924/agentshield_0.2.924_darwin_arm64.tar.gz"
      sha256 "5e4fd3ebbee1ba28b1a93fc91f54a58b7778f41e434aa4e27318c88f808df72d"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.924/agentshield_0.2.924_linux_amd64.tar.gz"
      sha256 "35d1a1dc2e5edb3053b058da11e82c7d57c3ac0b4819168d688aad43647e55ab"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.924/agentshield_0.2.924_linux_arm64.tar.gz"
      sha256 "4e340977465b07dc4c6f126b0b6afd229ee222185d8c7f2335c33622ef4d27f1"
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
