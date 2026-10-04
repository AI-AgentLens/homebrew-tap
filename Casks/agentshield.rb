cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2333"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2333/agentshield_0.2.2333_darwin_amd64.tar.gz"
      sha256 "dc6227f8c01f85baa0236c90db50c17fd8dfb0ff0badcf7411957a8ecf328ab2"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2333/agentshield_0.2.2333_darwin_arm64.tar.gz"
      sha256 "94941b8e4183d33f5c853c3b3fdc4732484740212c898640a07726fe672876ae"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2333/agentshield_0.2.2333_linux_amd64.tar.gz"
      sha256 "333ad600979e8ac4eb67e9d1e32d3663c5561751f4e2900597e1de6566df2554"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2333/agentshield_0.2.2333_linux_arm64.tar.gz"
      sha256 "ed6071a92fc5a4dd0ed8e90dcd6619630288cbc7bb83935dec80ed7048085407"
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
