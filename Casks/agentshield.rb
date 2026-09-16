cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2159"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2159/agentshield_0.2.2159_darwin_amd64.tar.gz"
      sha256 "2a90e80d42ce44999383c85010d1e6ce9bdd01931315b22e73a375c792b2f440"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2159/agentshield_0.2.2159_darwin_arm64.tar.gz"
      sha256 "8bb30ecfbe388af21a4746c64c64dd631c5109e267ef9f599dc8a61588581fb0"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2159/agentshield_0.2.2159_linux_amd64.tar.gz"
      sha256 "fd814c83e3fcb1ba7d8c5791cb5b7475393d56dab2e995f1eb30959649d47595"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2159/agentshield_0.2.2159_linux_arm64.tar.gz"
      sha256 "f41d4e0d0a0b43c9c601346f8a1a86d36c461966cbcbb37cccb8c52f0a62db25"
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
