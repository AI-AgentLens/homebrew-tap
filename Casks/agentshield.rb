cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1551"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1551/agentshield_0.2.1551_darwin_amd64.tar.gz"
      sha256 "ed5ddabdd5b4c2cf53fb519ce5a74c337203786fcc75244e3503e013423ebc8d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1551/agentshield_0.2.1551_darwin_arm64.tar.gz"
      sha256 "4980ca484109064e6cd5849c147eccd4da69de91ad5a8588d60e1427e4119e4c"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1551/agentshield_0.2.1551_linux_amd64.tar.gz"
      sha256 "0c675dc6b4518301cac32c237fd5ea098f964d5ed62031e135fc318490ea1c1a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1551/agentshield_0.2.1551_linux_arm64.tar.gz"
      sha256 "61abc2fcaaf13ba9ec4cf5948f91610ad1cd889af4ae048815bd2e6223c23873"
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
