cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.701"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.701/agentshield_0.2.701_darwin_amd64.tar.gz"
      sha256 "dda80b2bb4c9a106ff4f10f0ee35bfd9bf7551cf50601ee333bd191026381b2d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.701/agentshield_0.2.701_darwin_arm64.tar.gz"
      sha256 "619e3e4285b5a1ca72eb5e900615e2ac7240fa24079ecde6927892b08e14acf3"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.701/agentshield_0.2.701_linux_amd64.tar.gz"
      sha256 "587fb9882be2c6a03d3c6e03c85195a5b02a92293e2f1ffc698428dd0ccf942d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.701/agentshield_0.2.701_linux_arm64.tar.gz"
      sha256 "5e167992a867e14169d7f5f352f29770d26bad0a3aecb0ed38e3fd9e63d4cf8c"
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
