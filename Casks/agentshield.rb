cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.591"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.591/agentshield_0.2.591_darwin_amd64.tar.gz"
      sha256 "c0255c78f3fe747c3e78c068b559d13ef3084bb466d49536641f232e83654811"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.591/agentshield_0.2.591_darwin_arm64.tar.gz"
      sha256 "3a24a836aaf726ce182fc4c6b3bac8f8d637e27f043f4c969c8868a1bcf42c30"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.591/agentshield_0.2.591_linux_amd64.tar.gz"
      sha256 "28a2ad1598a3f56025111eaa01348d774e5ffd52d4d0a1d7927bca69b1d98dab"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.591/agentshield_0.2.591_linux_arm64.tar.gz"
      sha256 "6ef2479782424b82f1b755030148a0707b2ad5ec0c9e64f263b141f46bf94d46"
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
