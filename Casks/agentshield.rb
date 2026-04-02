cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.323"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.323/agentshield_0.2.323_darwin_amd64.tar.gz"
      sha256 "3f8615a9bb6f4e2948d0491a4989d72a1da38607e17b194533890332982838e2"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.323/agentshield_0.2.323_darwin_arm64.tar.gz"
      sha256 "f3038cab7ba141b087de589e367895c86dfd7e5bf6a4c9531187c5270b8b8164"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.323/agentshield_0.2.323_linux_amd64.tar.gz"
      sha256 "ca4c437351796542d6f2c401d5de1c8bfa8fa8654ae2d7157cbc5abfae6f53ee"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.323/agentshield_0.2.323_linux_arm64.tar.gz"
      sha256 "9eb88d11d8f039b074d6c289e95200aca9b0140500d88d2e490ab920a2f2e337"
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
