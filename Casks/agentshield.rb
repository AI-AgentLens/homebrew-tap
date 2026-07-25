cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1729"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1729/agentshield_0.2.1729_darwin_amd64.tar.gz"
      sha256 "9b6865829527af07d907c576eb47e28074a3ab878b58d7f5f16c6cef397a73c5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1729/agentshield_0.2.1729_darwin_arm64.tar.gz"
      sha256 "6d0d82739e269f2f51e678f4237de45cd0f55e45192bd7a0ea2f9d1aab523328"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1729/agentshield_0.2.1729_linux_amd64.tar.gz"
      sha256 "4dd3f77e34e67839e53579240385e0811e12a8485e4122d298069d66278d4779"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1729/agentshield_0.2.1729_linux_arm64.tar.gz"
      sha256 "f4fcb8581116c100e92fa0b137edee0a2bfa07b0acade46c82b073b3ddf9bb83"
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
