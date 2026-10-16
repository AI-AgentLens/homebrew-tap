cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2446"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2446/agentshield_0.2.2446_darwin_amd64.tar.gz"
      sha256 "6fe3863e2f414f884e0376ab380f03f7460e29c9108f3415887435842d3b81fc"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2446/agentshield_0.2.2446_darwin_arm64.tar.gz"
      sha256 "8cab313092059d5a569c2e08bea659ed0dd2c914eda697f6622e27c806f1af7b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2446/agentshield_0.2.2446_linux_amd64.tar.gz"
      sha256 "366e11c616c768d9839fc3e3d31a871d7de77a667e3bfb605eb4b5ff6dc615ac"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2446/agentshield_0.2.2446_linux_arm64.tar.gz"
      sha256 "44246277da3abb909c17592d7d16d1221658b77b09a48174d391eccd65bf6a3b"
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
