cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.935"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.935/agentshield_0.2.935_darwin_amd64.tar.gz"
      sha256 "ec108c39a291bd1ea3800d577375a5975aa9f8411baccaf6a0497739c3a40117"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.935/agentshield_0.2.935_darwin_arm64.tar.gz"
      sha256 "4f7b141b90369916f652ddc1f90e1944322e385d266ee4a30a9cf1a41aedda19"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.935/agentshield_0.2.935_linux_amd64.tar.gz"
      sha256 "1b77fbb52a9ed173bdbd0f3daecc0d64be72947c526c588e36a0924601315daf"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.935/agentshield_0.2.935_linux_arm64.tar.gz"
      sha256 "de6a08418751ed7b2caebc49d15af33c4740cdb44c41bcac890acba9e5da54e9"
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
