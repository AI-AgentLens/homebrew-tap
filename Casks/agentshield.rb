cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.575"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.575/agentshield_0.2.575_darwin_amd64.tar.gz"
      sha256 "e1a9ca4aa7732fe084673c95019bcbadbbedc80349a3af9ea82844216feb707a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.575/agentshield_0.2.575_darwin_arm64.tar.gz"
      sha256 "6e91bd31ad916479c18a43b80f1a8baaf6084c811f05cd5cd8ce86e4ec6d2580"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.575/agentshield_0.2.575_linux_amd64.tar.gz"
      sha256 "8d7268d3d6008048cf63da81f5067f3060f1992cf80daf6cc18e79eb7946efa1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.575/agentshield_0.2.575_linux_arm64.tar.gz"
      sha256 "6a58c7ba94e0abe46c357faa23abfdac8d607adfd045c93c326ea4b0e776dca1"
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
