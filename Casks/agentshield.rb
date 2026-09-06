cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2054"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2054/agentshield_0.2.2054_darwin_amd64.tar.gz"
      sha256 "12c56be08dbe6ca9a2480092d549515c50dfd16ce7bedc49515b3ba7c2e1c4f7"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2054/agentshield_0.2.2054_darwin_arm64.tar.gz"
      sha256 "d455e62e8bb0b9ec4f1a49dab472d4a99268c065f9efad7c871e8387a127fb5e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2054/agentshield_0.2.2054_linux_amd64.tar.gz"
      sha256 "0ae7c89f16bbea18aa5c8061bc39ef148fcf6848a456d3c48ebf840d01963fcc"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2054/agentshield_0.2.2054_linux_arm64.tar.gz"
      sha256 "0d0cbfff2264d3641425ccd9d911c238348dd1390fed6aca5870a5ead6e2ebd0"
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
