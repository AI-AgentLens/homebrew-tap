cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1505"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1505/agentshield_0.2.1505_darwin_amd64.tar.gz"
      sha256 "2fa1bb1967b8e0d17b5b883fdf9191059feed872dc76ada639d70e23c20ea832"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1505/agentshield_0.2.1505_darwin_arm64.tar.gz"
      sha256 "54790423eae0085c8666b51da2c153c61937e1d8f601500fa0f0c873084a1b8a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1505/agentshield_0.2.1505_linux_amd64.tar.gz"
      sha256 "713044f79b72e491415c8090a3d331182abfab212f8e8c86c0ebf6fee99f3470"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1505/agentshield_0.2.1505_linux_arm64.tar.gz"
      sha256 "2d8585d1255246b8399841a96000977c3b2a47d5220f3fd55aaf1e15a1bdaadb"
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
