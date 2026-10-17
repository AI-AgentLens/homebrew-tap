cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2453"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2453/agentshield_0.2.2453_darwin_amd64.tar.gz"
      sha256 "b0119fd35906b65b3d7928600de4517f2f0aaeff0b50d523ea03f8cb5506863d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2453/agentshield_0.2.2453_darwin_arm64.tar.gz"
      sha256 "f27b912e86623b4938fdd8280af014f067221726a827f12cdfe2ed4a5a4e774d"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2453/agentshield_0.2.2453_linux_amd64.tar.gz"
      sha256 "eff2a8341ff7c2b7b43c3c27b34142cd8766237e0bb1a194c6d1ef117636ea3e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2453/agentshield_0.2.2453_linux_arm64.tar.gz"
      sha256 "3b278e38931450106a0102bf28b3ac8cbdcb8d4cfdec67249e7c72025f7f644f"
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
