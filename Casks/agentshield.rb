cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.809"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.809/agentshield_0.2.809_darwin_amd64.tar.gz"
      sha256 "99d12e3bc245166647f6b74891e7432b74a40096dcd1318111422d400fc0841f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.809/agentshield_0.2.809_darwin_arm64.tar.gz"
      sha256 "cae5cceeea89638f806ab1197103cd1f03cf3dee55e9af455dcf6a2f0fc68a27"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.809/agentshield_0.2.809_linux_amd64.tar.gz"
      sha256 "8bc9561d275975db692cde9d38f5e712cee9e9510432644ab2bf1ce61d34b839"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.809/agentshield_0.2.809_linux_arm64.tar.gz"
      sha256 "8b2a0b3e6721f3595f32df79f180db4645dde29714837bbef919fe39751d96fa"
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
