cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1996"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1996/agentshield_0.2.1996_darwin_amd64.tar.gz"
      sha256 "c5be18e8572d7c7dc5d6b9fcd6bc3a911c0a654cefa056f6c9f2ef14ca1fd55a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1996/agentshield_0.2.1996_darwin_arm64.tar.gz"
      sha256 "80e96dc24655f50c4b747a48c9126acfe8c580818bee195c4aae10682679fd4b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1996/agentshield_0.2.1996_linux_amd64.tar.gz"
      sha256 "f1607e5fc5427657cfb2ea47cbafaf1472076ef50842caf4af891f1d8e25bee5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1996/agentshield_0.2.1996_linux_arm64.tar.gz"
      sha256 "eca478ca5ed779f41a92fb1f883bfcd6f3fc85e3cf8d0f6f752fcb4741a2585d"
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
