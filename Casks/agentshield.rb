cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1855"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1855/agentshield_0.2.1855_darwin_amd64.tar.gz"
      sha256 "ee24c50ac3eca627a9ccb65ac48b7a32252c0c5ebff4e3dc8ad98941adc0be35"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1855/agentshield_0.2.1855_darwin_arm64.tar.gz"
      sha256 "f12f993ef8384652150f4651ef6f0f3a836dd65188c760a5fa59a17ce1a6f240"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1855/agentshield_0.2.1855_linux_amd64.tar.gz"
      sha256 "db917fb0bc8e6d75480cb4440e92a047e6becd4eca9e41e4e6fb941737e390de"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1855/agentshield_0.2.1855_linux_arm64.tar.gz"
      sha256 "aa28abc548b5776d7cb56d7a1829836014dc8c23cb1f3e6a611e9444dc8fa4a8"
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
