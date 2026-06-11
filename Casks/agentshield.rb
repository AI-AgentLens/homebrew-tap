cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1279"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1279/agentshield_0.2.1279_darwin_amd64.tar.gz"
      sha256 "a6a6043edeba8fde817158c7e21af27e07689406e0de673a776373efc5639822"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1279/agentshield_0.2.1279_darwin_arm64.tar.gz"
      sha256 "4a1ab2e10af868f3b813bb11eec5a7580538dc2612b5bc9a5c21a97e3b2c11a9"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1279/agentshield_0.2.1279_linux_amd64.tar.gz"
      sha256 "6ca32eac5683d7b1cdd3308ef398f99fc1fcf000d8a458b6881cf659799732b5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1279/agentshield_0.2.1279_linux_arm64.tar.gz"
      sha256 "fb5b10a393b0153a38f5eeb398a2d8ea45a7ec511be0fe868bb34940526d1a57"
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
