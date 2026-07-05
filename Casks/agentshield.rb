cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1558"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1558/agentshield_0.2.1558_darwin_amd64.tar.gz"
      sha256 "051adb7507e60dcb2b7caeca6d820a914037bef7d02a3ec66e2f6ae247e862ab"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1558/agentshield_0.2.1558_darwin_arm64.tar.gz"
      sha256 "3ab3d1d6f5b2d154d48931cbf764a5ca2ece1664c974b2aea44355ec8b1d6b5e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1558/agentshield_0.2.1558_linux_amd64.tar.gz"
      sha256 "00eb1c55fcbc3ff94abffa45e6471111ce727447f7e01914f6a7cd8f586769a3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1558/agentshield_0.2.1558_linux_arm64.tar.gz"
      sha256 "6f18aa060ab6de3a80abe3905da107d26e6979168ea75f1caeaffda2fcd24fe5"
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
