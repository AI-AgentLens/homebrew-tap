cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.756"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.756/agentshield_0.2.756_darwin_amd64.tar.gz"
      sha256 "771ed1997ef5e0e6136eae69934dfe9213bdc5adc9bd5cd19d1a4d7b1da71e32"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.756/agentshield_0.2.756_darwin_arm64.tar.gz"
      sha256 "45d27a4e6becc137d2a690f2eebe310c0e68921b9cabb293b577156d79b8974f"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.756/agentshield_0.2.756_linux_amd64.tar.gz"
      sha256 "7415ce9b5d30298abb7c090f016ff40769948e6cd6ae01661942874ee7caf4ae"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.756/agentshield_0.2.756_linux_arm64.tar.gz"
      sha256 "f24d81647d2735a16b14b2a994cd5532929a6395dd9b824e3e48a0cf62e9b489"
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
