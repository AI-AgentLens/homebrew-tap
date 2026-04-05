cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.423"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.423/agentshield_0.2.423_darwin_amd64.tar.gz"
      sha256 "3b48a507e1e03122fcbf760ae7a12dca1fe05c712d385f7f1851e260eb9b61c4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.423/agentshield_0.2.423_darwin_arm64.tar.gz"
      sha256 "b899801af719c638e0d0b6f99974dd57168640afb07377f99e553dd6a029658e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.423/agentshield_0.2.423_linux_amd64.tar.gz"
      sha256 "bdcc76d7d34783cb05678a2707ef260075f5eea95280404bb4aa996b67012ec4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.423/agentshield_0.2.423_linux_arm64.tar.gz"
      sha256 "61db4ff2a39b496c7a11b0fa17f5e59944693fa113363a46bd3ce40aea82e1c3"
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
