cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.751"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.751/agentshield_0.2.751_darwin_amd64.tar.gz"
      sha256 "cccda612a3672d2b2ad908392a66e9c50c0d48ce89c2a4a8e1f47d8387dc4db5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.751/agentshield_0.2.751_darwin_arm64.tar.gz"
      sha256 "9264a47041074cb4cb9c6014e60d5288525a7d8966d6c8ec44392ad35f35d964"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.751/agentshield_0.2.751_linux_amd64.tar.gz"
      sha256 "1d219e0252ea19c18f8a95ee6e5693017ebb670f80e18c40d5c5fda6d1213369"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.751/agentshield_0.2.751_linux_arm64.tar.gz"
      sha256 "91c65c0c2f68cdf10f5021642357def07b61af3613164793f2c7c7b542d0594d"
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
