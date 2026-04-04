cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.366"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.366/agentshield_0.2.366_darwin_amd64.tar.gz"
      sha256 "b75c5af37953dc8820f1cf1bd1c54b3ebbda91306d5c6130f2f6ed6b564833b7"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.366/agentshield_0.2.366_darwin_arm64.tar.gz"
      sha256 "e08199022308aa96019014124d2f18ee7d0cf9b7f2aeadf7bf30bdb8f2b7f0d0"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.366/agentshield_0.2.366_linux_amd64.tar.gz"
      sha256 "3918027c286ee939816f23c373742e0d951408436872824f2738089cbe594df2"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.366/agentshield_0.2.366_linux_arm64.tar.gz"
      sha256 "3e80585b93645ac819f83ac7a9a57b040b38accfafc6af8ce7b8aacafd032979"
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
