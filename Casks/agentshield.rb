cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2192"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2192/agentshield_0.2.2192_darwin_amd64.tar.gz"
      sha256 "4b7cac13a6e2c7693718d5f824e11e2e24986361513b46722d649ae1879b63e5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2192/agentshield_0.2.2192_darwin_arm64.tar.gz"
      sha256 "e0bb477c0d584374cc396574d53060267480db0722c74f36ad44d0f26515ac75"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2192/agentshield_0.2.2192_linux_amd64.tar.gz"
      sha256 "3b09b06aacc69621cf717895384fd9446159e2caa79e21513a399ed8eca2209f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2192/agentshield_0.2.2192_linux_arm64.tar.gz"
      sha256 "1eb30f1ec29359e19c4075e7489758d33bd16caf8bdec94e1912e1f69497d94a"
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
