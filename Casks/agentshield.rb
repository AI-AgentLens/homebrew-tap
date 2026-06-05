cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1216"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1216/agentshield_0.2.1216_darwin_amd64.tar.gz"
      sha256 "5b7c4144ce597b3ffd4b2e6bc6869db942e38fc87a964af4594babedc88d0a24"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1216/agentshield_0.2.1216_darwin_arm64.tar.gz"
      sha256 "925b25da5e408dedf525af8d44e532c46c29263ec9d068ea4f79b4cb3427ae23"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1216/agentshield_0.2.1216_linux_amd64.tar.gz"
      sha256 "1fd35bedbc6052372b424e7ac93c3e7d4c759fd560c9010580f2736ed30da643"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1216/agentshield_0.2.1216_linux_arm64.tar.gz"
      sha256 "07d6ad2f41ec4a8cbbfd66726b570ef4c3de8a848a1cbefc409e37f02295a532"
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
