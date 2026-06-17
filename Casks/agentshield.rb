cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1351"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1351/agentshield_0.2.1351_darwin_amd64.tar.gz"
      sha256 "263186b3b60001ae7086c8702fd0c9bbfbed9571804eb0b74d865743affc8bd1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1351/agentshield_0.2.1351_darwin_arm64.tar.gz"
      sha256 "891334c365af6fe648fc3ad20de2ad2171912e31543250bd33ff6b8910bae140"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1351/agentshield_0.2.1351_linux_amd64.tar.gz"
      sha256 "6ecfd8f2e75a346e5aad11631004e9833b8e4120208fd0a206b2a4eedc8484d7"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1351/agentshield_0.2.1351_linux_arm64.tar.gz"
      sha256 "997ed606196c38fd697d7eed6faa8aa5e48d51877e709012024dd27ac0986993"
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
