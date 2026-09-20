cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2195"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2195/agentshield_0.2.2195_darwin_amd64.tar.gz"
      sha256 "73d9ed1450b3d223d6ace5b31d506e8c16607106f6c34bc0f7092b8ec1f47d5c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2195/agentshield_0.2.2195_darwin_arm64.tar.gz"
      sha256 "cc02031ffa58126d42ab4c9676abacc97901b2fbd72df522b77d1debcddcd043"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2195/agentshield_0.2.2195_linux_amd64.tar.gz"
      sha256 "a6b33c2db1a0531e0749a20d274b76c9082770badacb4ecf90dcdd58d7aefac7"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2195/agentshield_0.2.2195_linux_arm64.tar.gz"
      sha256 "bee7fba460bb77f231c7fac54f72b907945d6f4895936b894141f86b2701bf00"
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
