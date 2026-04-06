cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.435"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.435/agentshield_0.2.435_darwin_amd64.tar.gz"
      sha256 "d9e2b7c60ff71c4ffb83e89741be389c3cb367f73517b8c6b0a6b291c862e891"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.435/agentshield_0.2.435_darwin_arm64.tar.gz"
      sha256 "3ec580614377bffe4458e294486fb5df0f12ce99776ab413459ef04e6a9c3e8a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.435/agentshield_0.2.435_linux_amd64.tar.gz"
      sha256 "7a7aef975d640dc1dbbe80800faff1e2c1455e82ff0e01ba01b2d5d4146ba36f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.435/agentshield_0.2.435_linux_arm64.tar.gz"
      sha256 "a004752b5d290b4edb3dc5698cdff819f75030524189c43c906a3befa43d5939"
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
