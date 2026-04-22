cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.682"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.682/agentshield_0.2.682_darwin_amd64.tar.gz"
      sha256 "3f9c86e7d3dd72cf53d1ee8f114a05f657777d420b2dac5cd946dcb8638680a9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.682/agentshield_0.2.682_darwin_arm64.tar.gz"
      sha256 "1d144c5daccb3874c6e2a95acef16fe1487233fd02094edfeb8c56c4e06ac969"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.682/agentshield_0.2.682_linux_amd64.tar.gz"
      sha256 "d81410a1e2feb5dcfac6c31a39f6954d6cf4fe3c6ea41b55dfde1711d98a173c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.682/agentshield_0.2.682_linux_arm64.tar.gz"
      sha256 "e00c998d042e06dc81c5803df93fd0c5f45a4c00d6ae0e766f33b24e247c2623"
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
