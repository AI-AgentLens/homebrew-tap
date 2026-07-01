cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1520"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1520/agentshield_0.2.1520_darwin_amd64.tar.gz"
      sha256 "50a10f12461a5a44d0e481fb7a87b5e8d855eb2a23e9b13359095d5b3a7c02db"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1520/agentshield_0.2.1520_darwin_arm64.tar.gz"
      sha256 "107422946ab01779dbd6d0294e0c2ba42cc260b007d141a18eeec7ee0bfe54a4"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1520/agentshield_0.2.1520_linux_amd64.tar.gz"
      sha256 "df9955efdef03a6e19e37d46d5cfc7d16d2a46c6fc771cf3105574db3b1d2ae0"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1520/agentshield_0.2.1520_linux_arm64.tar.gz"
      sha256 "a37c8857ea63c1795d2b88b14e9c39999045fc446814adac89bcc608971504e7"
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
