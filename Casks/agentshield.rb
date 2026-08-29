cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1985"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1985/agentshield_0.2.1985_darwin_amd64.tar.gz"
      sha256 "495eb495f26d08d32f465cb11c7a88431015a9044042a76ba7c99816d1216405"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1985/agentshield_0.2.1985_darwin_arm64.tar.gz"
      sha256 "8528b47c4ff1fe4d5e72f89794f06bde475764da714096ffbfd6e54cdf3e6aef"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1985/agentshield_0.2.1985_linux_amd64.tar.gz"
      sha256 "bfe61e7e76c0fdc95c2792a394f88cb76f23b1ad72af4cbb60c58bbba838cc3f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1985/agentshield_0.2.1985_linux_arm64.tar.gz"
      sha256 "3f0e645eb77162c2bd912c1548cd134049ca964edd10dd5eef027e9031a1f2a8"
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
