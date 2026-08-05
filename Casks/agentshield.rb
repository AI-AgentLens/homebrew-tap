cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1795"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1795/agentshield_0.2.1795_darwin_amd64.tar.gz"
      sha256 "940f2efc735f627a54e35dc93fac8e5575e420d0d2e33a2d6a0a343b46ee9787"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1795/agentshield_0.2.1795_darwin_arm64.tar.gz"
      sha256 "e3a393a836c275f678320f858e6f28147db60e6cb4f4c93c153fde798a50a76d"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1795/agentshield_0.2.1795_linux_amd64.tar.gz"
      sha256 "1686df09bec06df8e0847680243f70d25219312ae5e1b3a0a14d4aa59b9b7073"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1795/agentshield_0.2.1795_linux_arm64.tar.gz"
      sha256 "2eeae6e8db98fbf3260d5c7c5b650273b5f48077244436a1e15a69d043f3f325"
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
