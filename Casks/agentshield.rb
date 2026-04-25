cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.719"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.719/agentshield_0.2.719_darwin_amd64.tar.gz"
      sha256 "8c6d9f9a0179bd83f16d64ef5211510f78b7395a32643c1d10a3e0594dd12d11"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.719/agentshield_0.2.719_darwin_arm64.tar.gz"
      sha256 "42c06c059c9aa3d651b365c3094a6c1ffb6eea41c4fff2ffb08e08d58ac8f17f"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.719/agentshield_0.2.719_linux_amd64.tar.gz"
      sha256 "07b4b5b4028678c77b7d965f4cc4a5cdd67881fc6049e0b1aa4e060e8b6ca77e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.719/agentshield_0.2.719_linux_arm64.tar.gz"
      sha256 "b42a96cfb44b867c771c6cdc74c9d2a0a32bcc50c4c2473ed6eb84241e1e575e"
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
