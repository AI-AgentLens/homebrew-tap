cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1086"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1086/agentshield_0.2.1086_darwin_amd64.tar.gz"
      sha256 "621afc0455c6ffc9990b27b5eba23cdc1a4781c0f23ae187de724f2fc076799b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1086/agentshield_0.2.1086_darwin_arm64.tar.gz"
      sha256 "1933c175bdb7b135d63c1ca37718052eab7f804c812061af55e4adc23695d022"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1086/agentshield_0.2.1086_linux_amd64.tar.gz"
      sha256 "40ac79ce7bd925a47daefad8ebd257320e63baf04cba6d050e22279c7d0f39ae"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1086/agentshield_0.2.1086_linux_arm64.tar.gz"
      sha256 "fe836bda6c0174fcb484a03fd7e17af177e96471fad6dcecd55dbf3dc0cea521"
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
