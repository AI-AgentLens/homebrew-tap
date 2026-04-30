cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.825"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.825/agentshield_0.2.825_darwin_amd64.tar.gz"
      sha256 "aa6898137e3795dd6dbf79d5e25d03790e660963b7d9be1283ba3445897043cb"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.825/agentshield_0.2.825_darwin_arm64.tar.gz"
      sha256 "61bd809b06131979bbea72234d7585ec6b395931ac323a54fc81e2d1584f48c6"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.825/agentshield_0.2.825_linux_amd64.tar.gz"
      sha256 "4ae236cda94823a64b247c9194f0d831ba366fd4737de6dbb08709b56fffbf90"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.825/agentshield_0.2.825_linux_arm64.tar.gz"
      sha256 "a50fe384a5609c57ce87a9b3a1179ada60e8d159f06cc4360d9ba564a4a35564"
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
