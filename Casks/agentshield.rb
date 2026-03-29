cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.206"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.206/agentshield_0.2.206_darwin_amd64.tar.gz"
      sha256 "72002af080d53f9d2d71c571d1fe64160983076a0bb991ee1482607035aff455"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.206/agentshield_0.2.206_darwin_arm64.tar.gz"
      sha256 "1ea68c55a35e5ca8d746c9aa5300c58565c17abfdb2b3aa3c7a6d6c30ba70a72"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.206/agentshield_0.2.206_linux_amd64.tar.gz"
      sha256 "7256bff8d76f9178b6156c56672951da37393403645c1efa05dcf4536cec3a14"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.206/agentshield_0.2.206_linux_arm64.tar.gz"
      sha256 "68368416b97c4e2b0f28ceaebd23262d684629c901a6c87b36a747488923b60c"
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
