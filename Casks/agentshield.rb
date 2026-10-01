cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2309"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2309/agentshield_0.2.2309_darwin_amd64.tar.gz"
      sha256 "dfda14514c34d4dcd66bb8e32121b8361cc0d1840ac2dc63cab0dee289aff75f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2309/agentshield_0.2.2309_darwin_arm64.tar.gz"
      sha256 "d0a4c0539ab1ce535d277ea74cce2fff290701ce9124fac8a724d0395fd8be58"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2309/agentshield_0.2.2309_linux_amd64.tar.gz"
      sha256 "cd6a04ac6f0e75e9929d2b94e5f7e9e30845fa1983d2c9aac0405da863f18ac6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2309/agentshield_0.2.2309_linux_arm64.tar.gz"
      sha256 "092a1a74cc7cf50bb5666a65f3b7e0b6b57c25d5a16df18b94936d4f5b7e3bf2"
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
