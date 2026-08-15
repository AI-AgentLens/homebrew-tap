cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1869"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1869/agentshield_0.2.1869_darwin_amd64.tar.gz"
      sha256 "8afe7187914ebce6ea38e4fd09f25b1ec9b7df9d7b1f06e538d37c1d56499d0a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1869/agentshield_0.2.1869_darwin_arm64.tar.gz"
      sha256 "e47284bc017096a8fcfe77cf20b2d856e62a3f640577615a3e26c3298fd1a788"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1869/agentshield_0.2.1869_linux_amd64.tar.gz"
      sha256 "066b0fbf19d0be17665fc5bf4d701e2d636c2b773a5590fdfbb80677ff1c6d34"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1869/agentshield_0.2.1869_linux_arm64.tar.gz"
      sha256 "39057684f5da70add46d5589f21d3558852829bf4a91a914d27c454b3f59dd25"
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
