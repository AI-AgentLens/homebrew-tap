cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.108"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.108/agentshield_0.2.108_darwin_amd64.tar.gz"
      sha256 "003413acb951709b65fd4dc5a1e8cae7f61912322bfedaaa2b14d71c4ec8f2bc"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.108/agentshield_0.2.108_darwin_arm64.tar.gz"
      sha256 "f9a55545f0ad380ecd6aed57f6dc719c9e76e88e351ff6f3c932f4930e98e627"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.108/agentshield_0.2.108_linux_amd64.tar.gz"
      sha256 "93d5663c93ad9e9d80d66bee10f59edd582cda993c081f190ad48ebe23d95695"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.108/agentshield_0.2.108_linux_arm64.tar.gz"
      sha256 "3560829f7a1380b17f2440c06fc2e8a476750d2aeaf33d00aa45379927098d0a"
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
