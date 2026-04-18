cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.633"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.633/agentshield_0.2.633_darwin_amd64.tar.gz"
      sha256 "ebb94774f6799c25f410ace32dd7119a0c876e4ae69876df76732bdcbca46f31"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.633/agentshield_0.2.633_darwin_arm64.tar.gz"
      sha256 "abf173997bc58f633c1b97e8f44c2468f4f20da68669087775ad8cf667af310d"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.633/agentshield_0.2.633_linux_amd64.tar.gz"
      sha256 "cc99ba831b8bb84fafff90ef629c37980c16885989566f4282ac530bdcd54af2"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.633/agentshield_0.2.633_linux_arm64.tar.gz"
      sha256 "ba72996dc267cc30b9d00a9773f63b365017fb8e659645a2e6d1dc1568acf5ec"
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
