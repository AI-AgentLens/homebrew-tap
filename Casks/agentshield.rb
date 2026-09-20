cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2207"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2207/agentshield_0.2.2207_darwin_amd64.tar.gz"
      sha256 "f52699dc112f66f79ce5af3fb357269dca4f6eea7802e2c50e25a45dfef058d8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2207/agentshield_0.2.2207_darwin_arm64.tar.gz"
      sha256 "0194e4e792f5ddad00319dbf4c571f6c29d3c96b2ea4603f70ef59164c185d21"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2207/agentshield_0.2.2207_linux_amd64.tar.gz"
      sha256 "c561cc468e2c5359389572d03487205a872abd51fa7e5a09d5734346a0350263"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2207/agentshield_0.2.2207_linux_arm64.tar.gz"
      sha256 "6d63508cbcd269ace7a1c3ca8fcffee3cbd2f9c64e0339cfd71413085ea683a8"
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
