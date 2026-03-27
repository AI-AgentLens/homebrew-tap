cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.90"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.90/agentshield_0.2.90_darwin_amd64.tar.gz"
      sha256 "4fa1f9da37bf26e814b7ad6100752d5185f4c4887a267f20b59428db85071158"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.90/agentshield_0.2.90_darwin_arm64.tar.gz"
      sha256 "a24b403bb944c218a0e6a410c930a368737ebcc4c9a79ef6f5089be22092d13e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.90/agentshield_0.2.90_linux_amd64.tar.gz"
      sha256 "3a2d4827b387db643a36f2371ff5e7eb9fbd75e44c2397747ad291b2af191cb1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.90/agentshield_0.2.90_linux_arm64.tar.gz"
      sha256 "5c7491f7af18354680ce96d1baa1ee3efd6d23fdfe2c3ae84419a1edcfdbb4fd"
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
