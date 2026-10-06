cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2353"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2353/agentshield_0.2.2353_darwin_amd64.tar.gz"
      sha256 "1609c5ee2089fd617cd09e8728e3e6f9ec0a408d9c16abcafc33c27bf7169646"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2353/agentshield_0.2.2353_darwin_arm64.tar.gz"
      sha256 "8a87ea92e7212532d4023bca6381e8047b7ce5864dc6e61c61921012b3b4c660"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2353/agentshield_0.2.2353_linux_amd64.tar.gz"
      sha256 "6aa2551dcc1a4d2c039efd1fde5702520bf499a1253bb3dff5633e39e560db44"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2353/agentshield_0.2.2353_linux_arm64.tar.gz"
      sha256 "847ce273040bb2a47c6c1e019f60a0d7a22cb2b08bb86e44b2b0ac8802aa51f1"
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
