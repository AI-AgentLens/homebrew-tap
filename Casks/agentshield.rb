cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.83"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.83/agentshield_0.2.83_darwin_amd64.tar.gz"
      sha256 "0cb99dcb0125f7c60451e0fddd6645c6d4d4617fabe3a489aa3aebf4d91462c7"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.83/agentshield_0.2.83_darwin_arm64.tar.gz"
      sha256 "4b2a38e37536364bd1c2a723039899e3e011830e4ef52188ce6a19c2e9a5edf0"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.83/agentshield_0.2.83_linux_amd64.tar.gz"
      sha256 "e9bd0888bd9b2564f32492bb2a3f8fa6558cc3b4899bac261f3d4636dcc4612b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.83/agentshield_0.2.83_linux_arm64.tar.gz"
      sha256 "41eeda0accaa8996d34f0752ba976737fbc1403e473691fc06c7071773fa1048"
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
