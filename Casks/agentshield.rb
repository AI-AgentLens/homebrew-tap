cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.262"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.262/agentshield_0.2.262_darwin_amd64.tar.gz"
      sha256 "09d89e90ec11e5be5962bf3ea21a126a957e30191141997bb21e1b5160747a39"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.262/agentshield_0.2.262_darwin_arm64.tar.gz"
      sha256 "d0127f2f87a974ba4401dc7417d9ba57eca5aeb845d9f44240ef0903aea31345"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.262/agentshield_0.2.262_linux_amd64.tar.gz"
      sha256 "f966c3944a4dbaa128f983cdd83a48a51e0b5194cb590f8e3565c967dd453ed8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.262/agentshield_0.2.262_linux_arm64.tar.gz"
      sha256 "fe3595ad4881d9f18bb0d12e125d004914c9fd84b1e1e571d00d48f4b72b6854"
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
