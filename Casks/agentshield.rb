cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1737"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1737/agentshield_0.2.1737_darwin_amd64.tar.gz"
      sha256 "529d87187b1e90d54ed2eb2b7c31a0178fe840b771e1b7c20b7718b7c48cf3ca"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1737/agentshield_0.2.1737_darwin_arm64.tar.gz"
      sha256 "3ec39487a9ea63e115f598a1f8cb103f086ad7bc15e8ab8370222cbc15fa59c0"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1737/agentshield_0.2.1737_linux_amd64.tar.gz"
      sha256 "06a994309ff5fb154237650b0cf559d9bc67859650aff4cecccdd1f75954189d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1737/agentshield_0.2.1737_linux_arm64.tar.gz"
      sha256 "961bb92a856ac9ecc4040745e2ffab42d54879c9152d71ba292d3023041a3963"
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
