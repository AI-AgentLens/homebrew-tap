cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2097"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2097/agentshield_0.2.2097_darwin_amd64.tar.gz"
      sha256 "a8bae49d03aed9d66bca5052142337da2aac9fd08b5038f3c5a9476e4e52d04b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2097/agentshield_0.2.2097_darwin_arm64.tar.gz"
      sha256 "c4ef88e449c1ee32418d3791078233917d7e7b6f4a9736146dd0690dc30ea6ec"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2097/agentshield_0.2.2097_linux_amd64.tar.gz"
      sha256 "51d8245a5efacfd307ddc3f18fbc06d6d0ea8a5a12930b3a2001e966edda2439"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2097/agentshield_0.2.2097_linux_arm64.tar.gz"
      sha256 "2221f7d3a9bf058f6c6ca3884abb487f7886b2b280ae327e72246be05db2ee9a"
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
