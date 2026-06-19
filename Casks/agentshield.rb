cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1366"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1366/agentshield_0.2.1366_darwin_amd64.tar.gz"
      sha256 "9a07016637b5f7822f8ccab55a170bc8b0372e8cd256f614533fa185659a8ae0"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1366/agentshield_0.2.1366_darwin_arm64.tar.gz"
      sha256 "ac22e0e8485e4874573fb694a3c0da6bc72ead1dfd5f54f20dc6ca9c20ee0780"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1366/agentshield_0.2.1366_linux_amd64.tar.gz"
      sha256 "d4974764f99da039debd22adbf1bcaaa39040ca52b12a883ee1a5fa1544992a5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1366/agentshield_0.2.1366_linux_arm64.tar.gz"
      sha256 "4842a41f40cc8ede1b5b55b2a34b0d539cc4496bfdf06226ebbeb4ad88a66df7"
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
