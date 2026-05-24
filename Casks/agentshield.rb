cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1115"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1115/agentshield_0.2.1115_darwin_amd64.tar.gz"
      sha256 "5c5d5e01c3a5f937cde73643d500062db85440dfc37dccd1a91609c74115204d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1115/agentshield_0.2.1115_darwin_arm64.tar.gz"
      sha256 "fb913157cfbfc7cc52b7fee98ca029134115263f299a81483b2c3393d7329f63"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1115/agentshield_0.2.1115_linux_amd64.tar.gz"
      sha256 "d935c9a3bdd9facee523a8cc2b884c0173b598d6eff39c528dd51d69507cc722"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1115/agentshield_0.2.1115_linux_arm64.tar.gz"
      sha256 "49cb2727627e510343e597e54164dab60fe8887dc46c49757b119a9b56dfc622"
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
