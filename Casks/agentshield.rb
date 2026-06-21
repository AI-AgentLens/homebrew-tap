cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1393"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1393/agentshield_0.2.1393_darwin_amd64.tar.gz"
      sha256 "969cb4baef48a2c40606073cee8921e94b44cfc6dad8f7571a5d502d514e8869"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1393/agentshield_0.2.1393_darwin_arm64.tar.gz"
      sha256 "1aea36de65e96059812b06b43ba9ce89d3e18ccc67acfde3b870aabd9b561033"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1393/agentshield_0.2.1393_linux_amd64.tar.gz"
      sha256 "ecd0ac44633fb596772fa2651c3945da646c995f6d9182acc3fe80396dc2ff6c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1393/agentshield_0.2.1393_linux_arm64.tar.gz"
      sha256 "9a3ad731a2f625f4b47a7ddbc8b771f74fcf041adfaa068c231d004b8858c177"
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
