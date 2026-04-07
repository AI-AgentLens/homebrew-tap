cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.460"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.460/agentshield_0.2.460_darwin_amd64.tar.gz"
      sha256 "d03ade5d76a90fb90c4881a8f268f785358ade311b9aeeb0273a0e14375b3069"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.460/agentshield_0.2.460_darwin_arm64.tar.gz"
      sha256 "a0d650eeab5176bb474ad97b8a63b239fdb3f1845e9cbb287755a42e180acca1"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.460/agentshield_0.2.460_linux_amd64.tar.gz"
      sha256 "17abc4cee01084c6a5d9e891fef685c8b8e8ba5485a276545a1600f098ef919f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.460/agentshield_0.2.460_linux_arm64.tar.gz"
      sha256 "dc14b5f36d76d14e466290f1a0dd3b6ef35784adbf078560d62093252272b3e1"
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
