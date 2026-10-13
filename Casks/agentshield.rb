cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2420"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2420/agentshield_0.2.2420_darwin_amd64.tar.gz"
      sha256 "8f70668b14da3ac9dabeaf26a52a37c2b5f34711f8b752e51b007bf4148b0373"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2420/agentshield_0.2.2420_darwin_arm64.tar.gz"
      sha256 "dde07f14af99ed6fc7552bc32c62f58270d4f4afeb5036b4a84d2228cbaf80c0"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2420/agentshield_0.2.2420_linux_amd64.tar.gz"
      sha256 "a9123c5b662bff1e38d97a841f75a6a2ebd7df6967237f9e73fa1106140118b4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2420/agentshield_0.2.2420_linux_arm64.tar.gz"
      sha256 "66f24c90a0e88de7df7f4284e94672b1065e1154eed5f844061187ef795a3856"
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
