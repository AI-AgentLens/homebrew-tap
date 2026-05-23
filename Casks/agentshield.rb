cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1097"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1097/agentshield_0.2.1097_darwin_amd64.tar.gz"
      sha256 "894255fc9eb32ce9f15d0c85c4de1eb729bf4f5da5bf701ebb537fd3233a02d4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1097/agentshield_0.2.1097_darwin_arm64.tar.gz"
      sha256 "de9e0e80330532e3e86df5caf5e8b119da150416ace1c82b92c3fe952e35ea8c"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1097/agentshield_0.2.1097_linux_amd64.tar.gz"
      sha256 "ed6d587f4cbcb168a12f41650b4beddb6a7d2a599d3df8326b76008abe2a7deb"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1097/agentshield_0.2.1097_linux_arm64.tar.gz"
      sha256 "1eff688a4667badb958642623ef8cd689fd96c6594da1a9ee0a6d0be3f338916"
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
