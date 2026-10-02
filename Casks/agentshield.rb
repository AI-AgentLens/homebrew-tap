cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2317"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2317/agentshield_0.2.2317_darwin_amd64.tar.gz"
      sha256 "cf1e52899ecb6f42147fb5044bbd6381aef50540f3ee66fe101da885bd886aea"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2317/agentshield_0.2.2317_darwin_arm64.tar.gz"
      sha256 "ae118e594046c15b50e2fb24424204f9ff9954343d53c7759ddcd7464ec53f26"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2317/agentshield_0.2.2317_linux_amd64.tar.gz"
      sha256 "937f613b8ad57ac6b45772ffcf4b782a4eb69f9ba0d9748c6b05570cc31b5a4a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2317/agentshield_0.2.2317_linux_arm64.tar.gz"
      sha256 "5fc9c448525118e3c6c2c23d175dc75eb941b1cde42f20de2ea5571920b8d82f"
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
