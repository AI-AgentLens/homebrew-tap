cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.988"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.988/agentshield_0.2.988_darwin_amd64.tar.gz"
      sha256 "dff0cc2708d0b41202b766a719017dad8c7c32038fc80418f78affbb86cb1793"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.988/agentshield_0.2.988_darwin_arm64.tar.gz"
      sha256 "ed7bee266918fddf9b7ed8519dfe83482e95faf23ebf7c21f377b59843a117a8"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.988/agentshield_0.2.988_linux_amd64.tar.gz"
      sha256 "c25da182cd7522335f9c011518a5c2d58439a33d0e48170785eccee03d97bf98"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.988/agentshield_0.2.988_linux_arm64.tar.gz"
      sha256 "c816ab15cc077f05f305172f4ea153d31541c08de1a64d5330f8f4ae33e86e1c"
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
