cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1497"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1497/agentshield_0.2.1497_darwin_amd64.tar.gz"
      sha256 "ed8683b04e4dcf82efa30cd5e3f9b7e3bc72bc06db461316264fbd9f1f20d674"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1497/agentshield_0.2.1497_darwin_arm64.tar.gz"
      sha256 "ef214e14b121ba54b88b4231130879109500a277ea00822603d3a9fdd4f2559b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1497/agentshield_0.2.1497_linux_amd64.tar.gz"
      sha256 "5a1a263783bf71e981e442c70a24624954319d01cd0eec9e61a87bb7dd46247a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1497/agentshield_0.2.1497_linux_arm64.tar.gz"
      sha256 "2b4e2f9add13dd75bff93880edacd101193a772271f57bf1d08c4f8659fda0df"
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
