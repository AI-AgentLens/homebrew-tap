cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2202"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2202/agentshield_0.2.2202_darwin_amd64.tar.gz"
      sha256 "aeb1193a464456c99c620bd41937ffa023e653285d85235a3f8d76967f24a798"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2202/agentshield_0.2.2202_darwin_arm64.tar.gz"
      sha256 "dc373f4d33ecce797b39b1de1076062bded9d743edd4f4c4f0715598889f8453"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2202/agentshield_0.2.2202_linux_amd64.tar.gz"
      sha256 "31d85cbc5c175420a9128c427f72760a61f90a627911a57538241ac357e34224"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2202/agentshield_0.2.2202_linux_arm64.tar.gz"
      sha256 "ba3f1719e9e178e26638762f05ea4b3b77ab1ab762de6e0af4d0e30548ba1de6"
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
