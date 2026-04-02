cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.293"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.293/agentshield_0.2.293_darwin_amd64.tar.gz"
      sha256 "994b2e84805889b0e8280738c9f73a759bb9b963aaca34326c3ae213ea39eb69"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.293/agentshield_0.2.293_darwin_arm64.tar.gz"
      sha256 "5678ce2e5dc5db75239d940de34e5758c422025b47bde2e7e16bba5280e2b43b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.293/agentshield_0.2.293_linux_amd64.tar.gz"
      sha256 "db2ff6fa5a61d7dbd655ab6ec652d477fc136fdc67531034d2ba6b13382368be"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.293/agentshield_0.2.293_linux_arm64.tar.gz"
      sha256 "b5a83b84c45b21733e74e7ebda67d5e514ae85723582d0c2c209f2f897085a44"
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
