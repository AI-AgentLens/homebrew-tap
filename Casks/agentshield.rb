cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1068"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1068/agentshield_0.2.1068_darwin_amd64.tar.gz"
      sha256 "10c0fa3eec52534eaba877c1a0f0066603c2e103fb5b25f3942aa35e629e4356"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1068/agentshield_0.2.1068_darwin_arm64.tar.gz"
      sha256 "4c8576ecb801cd3c5c40440c828b28bf5334840594de8bcec6afe255b55d805c"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1068/agentshield_0.2.1068_linux_amd64.tar.gz"
      sha256 "81a093b0ac696859af878c3b06f5d0d5801fbdcbea95bac3b386dacb41439697"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1068/agentshield_0.2.1068_linux_arm64.tar.gz"
      sha256 "80cf028f6e4935a6e63e7eedb955f67c7d4a25af2bffcf2a1ca19f77f7c0035a"
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
