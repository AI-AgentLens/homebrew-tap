cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1672"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1672/agentshield_0.2.1672_darwin_amd64.tar.gz"
      sha256 "9ec66c0d11728eca3a797655c000a5c79222d07960170e6493777741412f34d6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1672/agentshield_0.2.1672_darwin_arm64.tar.gz"
      sha256 "cb24ec84acd94e9f9f22630d725b45fb9f7d38e283918a309df72b38aea07cea"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1672/agentshield_0.2.1672_linux_amd64.tar.gz"
      sha256 "7cdf00629278a36c30c01b3c05fd4767d40d562a4fd2dabd43922229a40c8954"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1672/agentshield_0.2.1672_linux_arm64.tar.gz"
      sha256 "e95c4e06f6551ffae89061e0f0f8a2180a242cc3d6f6d23cb400f20978db5537"
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
