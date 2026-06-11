cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1284"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1284/agentshield_0.2.1284_darwin_amd64.tar.gz"
      sha256 "0f806c2e2e9fc20057a1e3568d5afe98d25fe255ddc78d7abf47b4a61b600180"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1284/agentshield_0.2.1284_darwin_arm64.tar.gz"
      sha256 "7a7d750a09b7fa455799457137d631c04d49b278a80e71509e07448e06f7c9e2"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1284/agentshield_0.2.1284_linux_amd64.tar.gz"
      sha256 "dfd2a37fafe2f624ef70c315ce1a86ff855fe9f7e17b38748102090f26d3e494"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1284/agentshield_0.2.1284_linux_arm64.tar.gz"
      sha256 "8c86f0d5192ccf776c8fe1fcf5a2ca79551e3a662896bb921decd44ed402e56c"
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
