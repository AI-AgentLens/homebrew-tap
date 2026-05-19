cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1038"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1038/agentshield_0.2.1038_darwin_amd64.tar.gz"
      sha256 "c791a4fad2a6b9c3271c1c80e2ad41438ad7d3696894bb56e102122673bcb0c8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1038/agentshield_0.2.1038_darwin_arm64.tar.gz"
      sha256 "8947d25c26e6bfecf2ca0f0ea74d5298c5d5d627ac6089a6ed193f05ba3e3a10"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1038/agentshield_0.2.1038_linux_amd64.tar.gz"
      sha256 "f9917d5a9c875cf3026a3b6070d7a1ce76ad9a030695f609c1d10d59fa962ad7"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1038/agentshield_0.2.1038_linux_arm64.tar.gz"
      sha256 "7147b662640cd709ade6f978dd5bc11300179f4189751ffea791741494dc1577"
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
