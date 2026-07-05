cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1560"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1560/agentshield_0.2.1560_darwin_amd64.tar.gz"
      sha256 "97176319a54d68ff04bf473b90c5d328ca45268a4a0828d52095b3dc3e5c48fe"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1560/agentshield_0.2.1560_darwin_arm64.tar.gz"
      sha256 "5a114952b18f8f044912e7bfb6ac10c7edbd15fa9b852b5df60d9c93e1d01283"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1560/agentshield_0.2.1560_linux_amd64.tar.gz"
      sha256 "06a5f84a73166f74d67ae8fcb41610195e569a8becc511a1bfd2e59177d9d73e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1560/agentshield_0.2.1560_linux_arm64.tar.gz"
      sha256 "b73ed9866d370223f1d4f3f6403202ce71ea38a202582d864490111055a4eddb"
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
