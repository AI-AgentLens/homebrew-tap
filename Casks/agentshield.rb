cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.487"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.487/agentshield_0.2.487_darwin_amd64.tar.gz"
      sha256 "54ceb1725b478f1aa9727be1b62a84e37e6f40ea758bdca830d8031c24c036f5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.487/agentshield_0.2.487_darwin_arm64.tar.gz"
      sha256 "8f73481555bc2a4efe96ae7e195e66e9dfac3e82eddc1ca01b5ef453d8a9ff0f"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.487/agentshield_0.2.487_linux_amd64.tar.gz"
      sha256 "ff14d1fa4c038677c82ff8e4ec80164246ebce1503fde00611b510a87f90670a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.487/agentshield_0.2.487_linux_arm64.tar.gz"
      sha256 "81210428b059470b224a793db8638b8a3a88b22faeb5f31920b6996b7337887a"
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
