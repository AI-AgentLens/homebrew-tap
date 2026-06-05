cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1217"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1217/agentshield_0.2.1217_darwin_amd64.tar.gz"
      sha256 "f14c90c80c392b9d055372910216d381e529265939162d24c0c815c7b241467f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1217/agentshield_0.2.1217_darwin_arm64.tar.gz"
      sha256 "0adf47ecff37beb91fa2479f5496836f0e61d162be1fef8dbd224582f666b577"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1217/agentshield_0.2.1217_linux_amd64.tar.gz"
      sha256 "0991b5c47319dc04bb4f246948efc558de7b6cd395177c6801bafb55235e4023"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1217/agentshield_0.2.1217_linux_arm64.tar.gz"
      sha256 "ab807841036d6bbcdd25a19a3ad158f03115965677c12a2bae950cba7bcf30db"
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
