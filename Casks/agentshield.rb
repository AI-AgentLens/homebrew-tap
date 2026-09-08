cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2088"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2088/agentshield_0.2.2088_darwin_amd64.tar.gz"
      sha256 "8041a3d3d60e0cf0cf86f0df3f1584b960b6803b5796ce1a6b19138874a6adbb"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2088/agentshield_0.2.2088_darwin_arm64.tar.gz"
      sha256 "eaa500ce7b86f236d39623bbddab223b9ed1f9ca9728001c8a64dea145b3fcd4"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2088/agentshield_0.2.2088_linux_amd64.tar.gz"
      sha256 "ec7d6438d7fcb143b535f77b271f243ac34f702ca49941c75eb344ba5b5875a6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2088/agentshield_0.2.2088_linux_arm64.tar.gz"
      sha256 "69d4a5320eda8d96f2b6015814f15f67c14b779f9bbf950271908d5764a8237e"
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
