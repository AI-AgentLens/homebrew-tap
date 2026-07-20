cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1684"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1684/agentshield_0.2.1684_darwin_amd64.tar.gz"
      sha256 "2f4478c8ab48b32253537e7e1f93a586cef894ee161245ea021ff0ef97ad9836"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1684/agentshield_0.2.1684_darwin_arm64.tar.gz"
      sha256 "5f5736dd78f786c89c8316e909fb28820686a0d445711bdd17549e06ead133f0"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1684/agentshield_0.2.1684_linux_amd64.tar.gz"
      sha256 "d88e7170f1ce5d44b5afbc697d73eb1472afb949a0e57c1d5fc247ef2e4ec63a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1684/agentshield_0.2.1684_linux_arm64.tar.gz"
      sha256 "23e39a5bdbe935c00eb55407dc8d09acb8217d94d7d07bba0111b892448a5766"
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
