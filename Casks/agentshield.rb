cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.252"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.252/agentshield_0.2.252_darwin_amd64.tar.gz"
      sha256 "712f6fe52b8a822d7baac07f9a1e8cbad4c56bc8e358f0fb5ee6e37f38c04b2b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.252/agentshield_0.2.252_darwin_arm64.tar.gz"
      sha256 "da545efa6d2192265fce2f13a71623813c28f7aaa7ebda947719c89b1d255226"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.252/agentshield_0.2.252_linux_amd64.tar.gz"
      sha256 "434aba98422905193d209b5a74bc6ff5b13ed07d4c9bbad3da8448496b485d77"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.252/agentshield_0.2.252_linux_arm64.tar.gz"
      sha256 "2bb3aa8d1ece01c3bf6b2d324774a1a81a51eae8bd4cd337c06c6cfd1f8b2fd2"
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
