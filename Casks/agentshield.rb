cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2258"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2258/agentshield_0.2.2258_darwin_amd64.tar.gz"
      sha256 "af1aced06290558fa24aeae7dcf2d101f5550e0f175dad188976ce9728eeb159"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2258/agentshield_0.2.2258_darwin_arm64.tar.gz"
      sha256 "cdea3dc5058f4570448bffd0588258d8e42cf9fa02562864a4358ec7d8d22e53"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2258/agentshield_0.2.2258_linux_amd64.tar.gz"
      sha256 "6534b24cdf9232e02232cd7111b34e6a80b9faf4dc3ff431d843c9b72171f043"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2258/agentshield_0.2.2258_linux_arm64.tar.gz"
      sha256 "5f3c4fc5c0b6ae812ad00cc93dee0480461661df3956047b9270b2c5b6261dc1"
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
