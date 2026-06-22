cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1404"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1404/agentshield_0.2.1404_darwin_amd64.tar.gz"
      sha256 "2e28122c610d84c7aba3c83294c7dd3706692e7160d4cf066f8da99240417ba1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1404/agentshield_0.2.1404_darwin_arm64.tar.gz"
      sha256 "056d2bbc4cd26fd45efd1029165d754718b62469bb4a8313d8e78ef87c86e794"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1404/agentshield_0.2.1404_linux_amd64.tar.gz"
      sha256 "bd516a5745440c04f112ecec31588ae0b90d537d34cf41412e85c448faf9bc24"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1404/agentshield_0.2.1404_linux_arm64.tar.gz"
      sha256 "bd373535b65e5c7bcf1f1f7c66ab58dc50bd8cbaca7a8f5e05316376aac58b73"
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
