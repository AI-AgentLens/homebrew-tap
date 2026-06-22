cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1405"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1405/agentshield_0.2.1405_darwin_amd64.tar.gz"
      sha256 "ae3e106bf1f0ac19da26aa8e617825ea88aa2916d79eb6359877a0831560a03b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1405/agentshield_0.2.1405_darwin_arm64.tar.gz"
      sha256 "58e10b96ff3750755409c2ed5e65b6a59208eed2168e4d443a1b37b44530a0b4"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1405/agentshield_0.2.1405_linux_amd64.tar.gz"
      sha256 "1bab1f43d7a7f44badb49ad5f3a7f0d3efe0f0937704cc186124dafda14ba636"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1405/agentshield_0.2.1405_linux_arm64.tar.gz"
      sha256 "7854ff0f4cafd54bf55b9224601bff8b05523f4a5df834356c878a832bd510dc"
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
