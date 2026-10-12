cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2408"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2408/agentshield_0.2.2408_darwin_amd64.tar.gz"
      sha256 "4a475da352ad0b1d570e1e5d3f813d1c8315e1a20fd19b0fa54930204898cf96"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2408/agentshield_0.2.2408_darwin_arm64.tar.gz"
      sha256 "dc959fb1c5bcb13aa6b412d7b8dc6b492364014dfacb4bb8449588d16d23ec7d"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2408/agentshield_0.2.2408_linux_amd64.tar.gz"
      sha256 "fae6bf5f1c1b68580e06775e06e20d3794acb3546e4881f8be1864b831a02a6c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2408/agentshield_0.2.2408_linux_arm64.tar.gz"
      sha256 "f4b1ca5c0cabab0ed566fbc960f9c6bfe49868285b9895281fea71972d0968ae"
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
