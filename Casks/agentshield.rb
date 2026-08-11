cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1823"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1823/agentshield_0.2.1823_darwin_amd64.tar.gz"
      sha256 "4b44268a1bfc4b11853ada7171dc29b21ca213541f3d2fd04b1e7c00cc6d473c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1823/agentshield_0.2.1823_darwin_arm64.tar.gz"
      sha256 "57f7ac88eab541e1db01378897318fef9ee451fd35ffe9771e784f2f6e4ecdd8"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1823/agentshield_0.2.1823_linux_amd64.tar.gz"
      sha256 "ea1fefcd2d952b673ff9e1105ae1a6b8ea76c2a7e59a1435f66f67728b8a6b95"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1823/agentshield_0.2.1823_linux_arm64.tar.gz"
      sha256 "426093292f6d30e355479fe718e02cc0b602b239483f5102411e9ad8b840cc83"
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
