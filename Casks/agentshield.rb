cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.675"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.675/agentshield_0.2.675_darwin_amd64.tar.gz"
      sha256 "365a7cb38724319d9a162bd21a45300be076d1f56815c56fdfd1ca23f3032929"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.675/agentshield_0.2.675_darwin_arm64.tar.gz"
      sha256 "0fd12fd5f87b68532cd69e02a6e5df9f5fea7f941ddbbd1790d2c1ecbf56bee7"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.675/agentshield_0.2.675_linux_amd64.tar.gz"
      sha256 "087fa623d57424e31539d813de80c743fc105965f43d609f72de5c3adc70fff1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.675/agentshield_0.2.675_linux_arm64.tar.gz"
      sha256 "ea4f024bd09d7dee6c61f0d566bc6b9d02ce40d711cbb9b2ea772959f79ec8a5"
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
