cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.526"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.526/agentshield_0.2.526_darwin_amd64.tar.gz"
      sha256 "0b299b901bfe2b06811ea3d30e36d023f38648e68fd54e47c77951e21279ef0c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.526/agentshield_0.2.526_darwin_arm64.tar.gz"
      sha256 "3d51aa7510f8f5608a86fc4700621d0dd86e9fe0bf203c9b5f404900e1d62bce"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.526/agentshield_0.2.526_linux_amd64.tar.gz"
      sha256 "58c61e831936b95bf414efa8d1e15f2b472d29af363492109b89e3620d1cf133"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.526/agentshield_0.2.526_linux_arm64.tar.gz"
      sha256 "a2c1450004d7531a0081479ef751f2d272fe8455e34571909dda5bb08039de63"
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
