cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.449"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.449/agentshield_0.2.449_darwin_amd64.tar.gz"
      sha256 "52c0b735622111543d29150c4f7f7f928dac261924f9d9a67b077ca005393e3b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.449/agentshield_0.2.449_darwin_arm64.tar.gz"
      sha256 "d4c38e0278128f43413bd7b1b46deba63e93ffc6c622caed7d1a8e58fc45d0cd"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.449/agentshield_0.2.449_linux_amd64.tar.gz"
      sha256 "7300cc42a4a2ae901f372ec7dfc4bb9f1a6574389d56a7909e8f42c7a1046523"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.449/agentshield_0.2.449_linux_arm64.tar.gz"
      sha256 "cdf63e2832bd83b3d0fe48ac23c7d7b38910c02a68ced68045445c307bd1af91"
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
