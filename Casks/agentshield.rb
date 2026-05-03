cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.869"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.869/agentshield_0.2.869_darwin_amd64.tar.gz"
      sha256 "0424e260bf611e33e31d1c061960db69f6ec9f6aecb1d3f33b60254c54cec3a2"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.869/agentshield_0.2.869_darwin_arm64.tar.gz"
      sha256 "60a59e0ba149f352414c980b390f720cf2d44fd2266401fdbda689240651656a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.869/agentshield_0.2.869_linux_amd64.tar.gz"
      sha256 "102dc1f5baeede212c5c8636cc3bd393a8191e771ae6f87422bd6972852a53a2"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.869/agentshield_0.2.869_linux_arm64.tar.gz"
      sha256 "e5de283371911378171998e9ca925da2ff2cf5be6908348cd03ea3f17e826844"
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
