cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.492"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.492/agentshield_0.2.492_darwin_amd64.tar.gz"
      sha256 "8849089f737e8fa0e9df3669e499e7494d72ec8e24e11eb3b40dd4c40498d723"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.492/agentshield_0.2.492_darwin_arm64.tar.gz"
      sha256 "fd11496f804291265b9177ed4999a7a9615f9b93e4cba96c7153008d86eb6bf6"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.492/agentshield_0.2.492_linux_amd64.tar.gz"
      sha256 "74f250bfb668a2a70472ef4006fc14d7dad7d74eef0d0dca893d96ae3b344942"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.492/agentshield_0.2.492_linux_arm64.tar.gz"
      sha256 "07d4cd887433761bb8f2d839cfb1b2c3c40bf309f0a41933d71b365c0af7eeed"
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
