cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.484"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.484/agentshield_0.2.484_darwin_amd64.tar.gz"
      sha256 "be102c404a6e1b00e611008c81d9dfbe92e4928d8e2f1302071388a8878854cb"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.484/agentshield_0.2.484_darwin_arm64.tar.gz"
      sha256 "6b48c1a310d5afc1aed9615fe8e0016a5687d355b448a54650b499266f5f4f1e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.484/agentshield_0.2.484_linux_amd64.tar.gz"
      sha256 "c29b1d8a2a0324540b529c8a73a1bffa4924ae3c9b9baf311703a8ee36729c3c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.484/agentshield_0.2.484_linux_arm64.tar.gz"
      sha256 "6a2cc0b250171949178360ebcc8bd96e040f30b2078f4245253f552889b83e7b"
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
