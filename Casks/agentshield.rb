cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.853"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.853/agentshield_0.2.853_darwin_amd64.tar.gz"
      sha256 "6bb6cc9de0b72473cb4558f9cea186628a74d1a8df297ec4babfd8b063a2c659"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.853/agentshield_0.2.853_darwin_arm64.tar.gz"
      sha256 "1a76823b4935456088de59dfdb097f9a6aa7c9bad4abec027dde64b4f73dd48d"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.853/agentshield_0.2.853_linux_amd64.tar.gz"
      sha256 "98bae850b0427b0a335f64fc9c9cf5ea9071ab9c99c2e6382ce99e59d149ee7f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.853/agentshield_0.2.853_linux_arm64.tar.gz"
      sha256 "9a2f8a11d3da4bbc3cd33a1130397affa9d8eb007b212be1600234eb4aeeef82"
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
