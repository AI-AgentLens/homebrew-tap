cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2440"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2440/agentshield_0.2.2440_darwin_amd64.tar.gz"
      sha256 "8ceedc0e4d94febe9ffa239eb8073cbb3263551a4b5305c106e2746368006e49"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2440/agentshield_0.2.2440_darwin_arm64.tar.gz"
      sha256 "f37a52ad0cc1f43a350adcbf22dddf482632f19dda1abfb331b5601957f78279"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2440/agentshield_0.2.2440_linux_amd64.tar.gz"
      sha256 "626a91ffa4214c56ab848936a05827c7379c0cada296a0907256a904ea786e4a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2440/agentshield_0.2.2440_linux_arm64.tar.gz"
      sha256 "a2092425a9fbea8fe180fa715d6bd1364ff63022e4c4c89627a5b25172ce7f47"
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
