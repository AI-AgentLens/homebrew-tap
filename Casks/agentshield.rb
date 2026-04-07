cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.466"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.466/agentshield_0.2.466_darwin_amd64.tar.gz"
      sha256 "ebb553530c27621cffe02e91325390cdc0ba2e609dbddaee3ca304b61fcd3f73"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.466/agentshield_0.2.466_darwin_arm64.tar.gz"
      sha256 "526596f5dfdf30520d1ed9bb0ce5cf0613b92f85b8b09c50c48ed6e99657c00b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.466/agentshield_0.2.466_linux_amd64.tar.gz"
      sha256 "fd59baed73106d5033e255c8313e9fd230d1be1e238ec6120922e82bfbe94d8f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.466/agentshield_0.2.466_linux_arm64.tar.gz"
      sha256 "cdc288316700fabf1f1f87ad1cf518a1a5d10519e14656211ed7aac09b7d1269"
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
