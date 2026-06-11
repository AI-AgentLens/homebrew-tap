cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1280"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1280/agentshield_0.2.1280_darwin_amd64.tar.gz"
      sha256 "81f7a0928ad218c9238c98958b612ad30fb82a91afca149880be0b5a5be5fcd8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1280/agentshield_0.2.1280_darwin_arm64.tar.gz"
      sha256 "2cc7794e99507c552b578bb3616878937a0da568e7e91b3bbb24cf6ed00373e0"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1280/agentshield_0.2.1280_linux_amd64.tar.gz"
      sha256 "e1a4cedf1ab0700dda4ede5ed533b95be09fdce73d340e9a035957821daafc5c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1280/agentshield_0.2.1280_linux_arm64.tar.gz"
      sha256 "3e9b9c1535b94e250490799fc5e23814145fef11a7bb4dbbe6774b4f12107d25"
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
