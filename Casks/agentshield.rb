cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1704"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1704/agentshield_0.2.1704_darwin_amd64.tar.gz"
      sha256 "aec78d372a788cc725c4364066b1536d77d3913edac38647f65a12f08f75839d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1704/agentshield_0.2.1704_darwin_arm64.tar.gz"
      sha256 "dd6f74550a5f3be0accfa50ebf5b34e9c3403641ec2fb687ce0038e4fbdedbb1"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1704/agentshield_0.2.1704_linux_amd64.tar.gz"
      sha256 "34037ca94100d43c416cf64bb418911823f5d02f6407dc929805e3286be835d3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1704/agentshield_0.2.1704_linux_arm64.tar.gz"
      sha256 "a6f5012935c038f180e140ad1d7a9cf8f14caf0e3ed3c94cb34a791420d15ca3"
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
