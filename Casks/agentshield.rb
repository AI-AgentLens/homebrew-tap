cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.533"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.533/agentshield_0.2.533_darwin_amd64.tar.gz"
      sha256 "3107301b7797af2cf8038569db65f845de0165a441bab9d4c852885343a5316f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.533/agentshield_0.2.533_darwin_arm64.tar.gz"
      sha256 "b5162ec5d4fcd5642a7b6f3ca89ac30f26ef82f341df18c36662364fe4ef0bab"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.533/agentshield_0.2.533_linux_amd64.tar.gz"
      sha256 "52e52405d2c11d7ed10c13600e20b5f56c0bc44dded65b10bdd02cd1f51e32d2"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.533/agentshield_0.2.533_linux_arm64.tar.gz"
      sha256 "b4158b2753fc1a9c07c3b7a7055c122f6427717a1c224af85d028068d51444aa"
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
