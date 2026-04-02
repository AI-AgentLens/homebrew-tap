cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.318"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.318/agentshield_0.2.318_darwin_amd64.tar.gz"
      sha256 "047f51b360fb7f5a53805675288599cd33f703b2c1823f986fbad8e13799a966"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.318/agentshield_0.2.318_darwin_arm64.tar.gz"
      sha256 "3233ab574cdc906ada0e58e604f0c901e94eb6f25c6189894835c93e04d68aa6"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.318/agentshield_0.2.318_linux_amd64.tar.gz"
      sha256 "7fecd92fbad9f06c985df02f66ac8d49d1a9f02b5d1e50048aaf1247c9f19cfa"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.318/agentshield_0.2.318_linux_arm64.tar.gz"
      sha256 "8a26a1b991ffb0238a082225093f549a35ccd5b5abc636d8e52cc1eea3d38bb8"
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
