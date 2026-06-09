cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1257"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1257/agentshield_0.2.1257_darwin_amd64.tar.gz"
      sha256 "a4636620648d14a0f5c9bd89aa9f535f273713ed2fc25470f3c5eabe84dfdf73"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1257/agentshield_0.2.1257_darwin_arm64.tar.gz"
      sha256 "d8c7c2d1715c5fa2dc28abcbacb248afb9895d3efa131ecbe4983976141ef609"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1257/agentshield_0.2.1257_linux_amd64.tar.gz"
      sha256 "99b99670b59035476ff9307383ebc89012017eb175b97cc10a69db720d4455ce"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1257/agentshield_0.2.1257_linux_arm64.tar.gz"
      sha256 "0ca586481713372eeefbc1fa623cf319dc4d121d584e966013df868a88cf040f"
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
