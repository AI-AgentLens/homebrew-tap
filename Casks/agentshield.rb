cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.232"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.232/agentshield_0.2.232_darwin_amd64.tar.gz"
      sha256 "2abf72a737236fddb642632fb93982974631cd3f636e5f5195a324bc7a1f2faa"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.232/agentshield_0.2.232_darwin_arm64.tar.gz"
      sha256 "6aeb67c16440bbe1c4b6cd25d6b66b794b5550afd4b79459bc750cf0743858db"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.232/agentshield_0.2.232_linux_amd64.tar.gz"
      sha256 "bdcc31a0e6b900ecefe20cf11e3976b174e1b13204431924dd7b976eef1ddc6f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.232/agentshield_0.2.232_linux_arm64.tar.gz"
      sha256 "91f0df0608044949c33a2eefd304511a2ae5a83029b824f1823e52c7bf880825"
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
