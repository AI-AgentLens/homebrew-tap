cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1523"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1523/agentshield_0.2.1523_darwin_amd64.tar.gz"
      sha256 "d3d312a76abf81d17c54a8490dffa70cebd392299d33d987aa296d0b6a45c2a0"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1523/agentshield_0.2.1523_darwin_arm64.tar.gz"
      sha256 "17f224894b9a46f8da9f178f80b2deaf5bf0d8fbac46aaa5197df27d1d3b5295"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1523/agentshield_0.2.1523_linux_amd64.tar.gz"
      sha256 "7ba7d3ad24333ec50e62ec43c688fa41f4ac19e909fadda5405a2fe5f416c05f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1523/agentshield_0.2.1523_linux_arm64.tar.gz"
      sha256 "0baeb2be3234e4455884f81d39097beebae8a174490f2ad69ec7b29309926df0"
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
