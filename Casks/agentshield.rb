cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1541"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1541/agentshield_0.2.1541_darwin_amd64.tar.gz"
      sha256 "d847c76f046aa3982ef10187afa3e2f29a560bef1b7216a4ab3b77083c0eef2a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1541/agentshield_0.2.1541_darwin_arm64.tar.gz"
      sha256 "200df7816477d1fa521e02819ee0ac1b34c93ffaf1ec1704842f35c969152787"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1541/agentshield_0.2.1541_linux_amd64.tar.gz"
      sha256 "6baa3aa098d639f5a6ae65444a5304c7da38ad41a457d83cd22c901a043b793b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1541/agentshield_0.2.1541_linux_arm64.tar.gz"
      sha256 "27cbf1c0b6e98dbd6bc97064203be546bb0fb13664f558953124d5c3907c4036"
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
