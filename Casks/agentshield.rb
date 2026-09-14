cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2145"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2145/agentshield_0.2.2145_darwin_amd64.tar.gz"
      sha256 "7819ea8f91cf98d38cc5d496be088ee46742a403c6a1ce69cee3001e0947b702"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2145/agentshield_0.2.2145_darwin_arm64.tar.gz"
      sha256 "570e0252d1d73f7a34c52dbaef6036393bba70a8024dac3c27b803586e56f41e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2145/agentshield_0.2.2145_linux_amd64.tar.gz"
      sha256 "da4e1445dc71f77566403da498c6f581c7336a84a908a8042d90e5f393a2440b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2145/agentshield_0.2.2145_linux_arm64.tar.gz"
      sha256 "de3b517ccdadecf9bf8e12ac98273bc1aa1860a44027d28a8fb4507b976ebfa0"
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
