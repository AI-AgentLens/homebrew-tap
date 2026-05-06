cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.888"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.888/agentshield_0.2.888_darwin_amd64.tar.gz"
      sha256 "a2ff10f5a26a72b17788241d7de42d6044fbe19633dda27a9850f9add691fd7c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.888/agentshield_0.2.888_darwin_arm64.tar.gz"
      sha256 "eee74f0c0cf4129749c7df504378a7693030b0583d0a8d502014d787992d3f8b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.888/agentshield_0.2.888_linux_amd64.tar.gz"
      sha256 "63f7d7cdbf7c1d0f10308f644d3d563953ccece7def449304aa50c7e5b51b230"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.888/agentshield_0.2.888_linux_arm64.tar.gz"
      sha256 "77c6a05f6995dfb5edd8a5de2e9db96d1616c2d09d8325a05b9d88502bae2686"
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
