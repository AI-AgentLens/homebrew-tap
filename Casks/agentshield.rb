cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2252"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2252/agentshield_0.2.2252_darwin_amd64.tar.gz"
      sha256 "5b56c5c2576fc9704af625de67e99c930266583ef685d25c3413cad37182debe"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2252/agentshield_0.2.2252_darwin_arm64.tar.gz"
      sha256 "a937b4969ff37e54de7ba65a12760f74f9ea079fade756f5c6dc6d38dc66adb2"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2252/agentshield_0.2.2252_linux_amd64.tar.gz"
      sha256 "f2aa5d66d4618a579a5791a827cbfd99ca2392ed056ddef26fa7a5565887f031"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2252/agentshield_0.2.2252_linux_arm64.tar.gz"
      sha256 "c15871df9abf2f94a559e796111f0aeb53cb12a1393bea300976f725ab933188"
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
