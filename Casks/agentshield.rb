cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1226"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1226/agentshield_0.2.1226_darwin_amd64.tar.gz"
      sha256 "a1e2371cc8256375b1a0d6ba383dd27385ace51a222d394b133eefafaffdfc83"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1226/agentshield_0.2.1226_darwin_arm64.tar.gz"
      sha256 "45fd5003b19b6746bfc1646b7ba83c8cdf95ef8ce6ad438b55cd17e74795f58f"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1226/agentshield_0.2.1226_linux_amd64.tar.gz"
      sha256 "7ff24950f377ae538ec132bd21a8798a786f39131ace440e4036a20a9c09598a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1226/agentshield_0.2.1226_linux_arm64.tar.gz"
      sha256 "8177e8aa13c9f47766db52e7ae07418f5c67b4a85584e171697d2fee84ecf756"
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
