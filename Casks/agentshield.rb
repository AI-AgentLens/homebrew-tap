cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1552"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1552/agentshield_0.2.1552_darwin_amd64.tar.gz"
      sha256 "10185d0eca2b55f0e11b28d89e6547b201693600c150bf4cbcd6b05a79c73bf5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1552/agentshield_0.2.1552_darwin_arm64.tar.gz"
      sha256 "e590e207bf4a5a6caa31c477726e68eba6ed5fa1a488c8b0c0a254c9c4f6becc"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1552/agentshield_0.2.1552_linux_amd64.tar.gz"
      sha256 "1df6fafc74f629cc39490433ec7636f8b952e16aaedce1275dc37162899ede72"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1552/agentshield_0.2.1552_linux_arm64.tar.gz"
      sha256 "d09c4cd72695b1432721c54b42f01c30654395015fa3eb5dba46279632629a29"
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
