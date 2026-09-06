cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2065"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2065/agentshield_0.2.2065_darwin_amd64.tar.gz"
      sha256 "3e90dd2bb7885a57d51a629f6d6c087cf4718703ca418b639c8d5c7c673c2a5b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2065/agentshield_0.2.2065_darwin_arm64.tar.gz"
      sha256 "fbbcb43f3970620ded1160cc9ac0a71a7429bae6dccf0eaa485d762ad93676cf"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2065/agentshield_0.2.2065_linux_amd64.tar.gz"
      sha256 "3de16a71a7d864cc88413f0e02c9a62a7b022d0e7b53e0087507c87e9578357e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2065/agentshield_0.2.2065_linux_arm64.tar.gz"
      sha256 "b089ed1d1ea8d74462deb71b2399654594e4b87994435cfbbeafe57e2e3a30fb"
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
