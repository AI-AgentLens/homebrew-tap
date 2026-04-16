cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.606"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.606/agentshield_0.2.606_darwin_amd64.tar.gz"
      sha256 "8b608a3c6843111efc69b1d375a3c0c0747c5805d7775bdeeba5b3ba49559f97"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.606/agentshield_0.2.606_darwin_arm64.tar.gz"
      sha256 "221238d84edf9e258152411cfc3e4bbb0967cc18f7dbea65f6a18b9db9bb5887"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.606/agentshield_0.2.606_linux_amd64.tar.gz"
      sha256 "f6d81fc634fc68152b45c8e520d7bdd4b1139bf947aa774edcb25ecb130f2c4b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.606/agentshield_0.2.606_linux_arm64.tar.gz"
      sha256 "7a155ace42a7279295a3a9b28e2bc6ea1c002dc398c897508548ddd02d6c6f5e"
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
