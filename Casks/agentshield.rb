cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2060"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2060/agentshield_0.2.2060_darwin_amd64.tar.gz"
      sha256 "6099b2bcef15d4dba3e46f09a8efe4796072342c638753111112688e2e4a2db0"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2060/agentshield_0.2.2060_darwin_arm64.tar.gz"
      sha256 "ee9f5080074ec377dcf8938a26228c13651d7012209ac88207b4ac6d7a064853"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2060/agentshield_0.2.2060_linux_amd64.tar.gz"
      sha256 "ed064d6861f7bbe46090db03a0905888259f93b31e634a91de2cc68bd8bc002b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2060/agentshield_0.2.2060_linux_arm64.tar.gz"
      sha256 "3b429e4f32e240d41287e62b4657473592e164563fd1f60ebfc5022c2d50a888"
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
