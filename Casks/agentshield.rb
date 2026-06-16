cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1329"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1329/agentshield_0.2.1329_darwin_amd64.tar.gz"
      sha256 "611613744d5aa1822ab08d3343fd9ac44b3bd8d4ebcc1388f981b3c21e156356"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1329/agentshield_0.2.1329_darwin_arm64.tar.gz"
      sha256 "1f84c041829f33bd8eaa82e0fd4a965cef61578ae1053da74521275e4a4be63f"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1329/agentshield_0.2.1329_linux_amd64.tar.gz"
      sha256 "d0a1969dccdefe97ce27c67c865718ec30357fdeff6c412423175f80def55b4a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1329/agentshield_0.2.1329_linux_arm64.tar.gz"
      sha256 "890fb58f0a9e901903943e9e24416b741c9e99b2507a90f5f11f5e3b572cfe1b"
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
