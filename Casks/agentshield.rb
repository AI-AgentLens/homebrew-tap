cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2371"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2371/agentshield_0.2.2371_darwin_amd64.tar.gz"
      sha256 "b83e3825488ea899bdf638258af512bd79476fc9f5a6c8304c50d19fcfcef1d9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2371/agentshield_0.2.2371_darwin_arm64.tar.gz"
      sha256 "b7af356d2fea97749e3e735ced75f6dfc986740c5647e9d2d18854c7867a0cd8"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2371/agentshield_0.2.2371_linux_amd64.tar.gz"
      sha256 "5f8639d0877ec0ab3c105d2e8623d67a2169eff6ebb64d97853a4ab0ba2badc3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2371/agentshield_0.2.2371_linux_arm64.tar.gz"
      sha256 "6223a6a4bcccc5dd3fca1db7783790814fde1882c968054e17ea36b0e08af047"
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
