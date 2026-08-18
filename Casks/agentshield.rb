cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1893"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1893/agentshield_0.2.1893_darwin_amd64.tar.gz"
      sha256 "2ef18e413b44c0193872667cb1cdfb73ca011dad280717dd39a53fff212bd1a4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1893/agentshield_0.2.1893_darwin_arm64.tar.gz"
      sha256 "ce7b534ca7927861924adcd2ff991f811bf68775ec0a6131328a75e2a24a02a2"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1893/agentshield_0.2.1893_linux_amd64.tar.gz"
      sha256 "2566c87b03928e526411b8d261740ef9db9321ceed9339e454ab729bba0b9316"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1893/agentshield_0.2.1893_linux_arm64.tar.gz"
      sha256 "e68a01019204e600adc2d1d9026d489a711d552a0f8979f5f683787e84eaa717"
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
