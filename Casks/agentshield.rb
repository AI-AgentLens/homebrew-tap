cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.314"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.314/agentshield_0.2.314_darwin_amd64.tar.gz"
      sha256 "2c31d493b2b81c961c8aa2dd9cf399df730ef09a5564179d7a926bc781a8c1dc"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.314/agentshield_0.2.314_darwin_arm64.tar.gz"
      sha256 "04a02b9e34422d7c3f14539689ffffe16972a58e25568c9aaa867f2db37c0b8f"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.314/agentshield_0.2.314_linux_amd64.tar.gz"
      sha256 "973023ab6fbe9700d3837d0cb32067c5b3b5685e0b0da95dc0c65a1369f4c37f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.314/agentshield_0.2.314_linux_arm64.tar.gz"
      sha256 "eea0e30a5d97a44e1e8006d35f9b9816861c9b6ba239d6b69ef4aced4b198474"
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
