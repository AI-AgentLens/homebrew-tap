cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1928"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1928/agentshield_0.2.1928_darwin_amd64.tar.gz"
      sha256 "1d023dd305342a8e2169b55a45f0356e6ef118bdb0bc8d06c24825780437f71a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1928/agentshield_0.2.1928_darwin_arm64.tar.gz"
      sha256 "b8baaa9e8d0ab58caf7f3e9a3c8097b38700395d24f97c4163662d3c2c280a59"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1928/agentshield_0.2.1928_linux_amd64.tar.gz"
      sha256 "9e1bfc38dfa0583d5ea9cc0f42976259ad2e7acd1f2548d9c3b3541f74616cfb"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1928/agentshield_0.2.1928_linux_arm64.tar.gz"
      sha256 "e8ecd7b20dfd422c41a48d9d9ce8794b9e87cf2b59b58520e3547d3bc7f5bf2f"
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
