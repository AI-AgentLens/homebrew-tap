cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2339"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2339/agentshield_0.2.2339_darwin_amd64.tar.gz"
      sha256 "490ca850a6f1c5ca2ed5efdb42346f61fd8abf16510a7e058821a1024afbb3fa"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2339/agentshield_0.2.2339_darwin_arm64.tar.gz"
      sha256 "107027c876539ed4c82061f0af0c41ec51ea8890d8a1f778ae6fb419251469c4"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2339/agentshield_0.2.2339_linux_amd64.tar.gz"
      sha256 "e9b62400cbad51d2dc89282448dee381d1abd8e44a61cc9d5bb87d29b9ef7eea"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2339/agentshield_0.2.2339_linux_arm64.tar.gz"
      sha256 "94f69a8b0f210c9cac45c19f7c67feb6fca2099e522fdfbd1a72733f447ffeaa"
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
