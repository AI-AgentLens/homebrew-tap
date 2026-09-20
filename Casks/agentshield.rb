cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2198"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2198/agentshield_0.2.2198_darwin_amd64.tar.gz"
      sha256 "187910af6e4141ecf92305533d09b1bac8d663b5f0b30281d6b2bfe67af7d6a3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2198/agentshield_0.2.2198_darwin_arm64.tar.gz"
      sha256 "7d63c85562842364d5d27ec6cd7098d6ede28f2e5a9a301c8882e232e98bec2b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2198/agentshield_0.2.2198_linux_amd64.tar.gz"
      sha256 "a237e9d05ff9e93ad2bf7250a29394015621e6fa8f0dd4f75fced2d3d863403c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2198/agentshield_0.2.2198_linux_arm64.tar.gz"
      sha256 "f5caf3b75e586ff7102d58c336451cb001ddfb363b8f9d0b0cce7d3d497e20e9"
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
