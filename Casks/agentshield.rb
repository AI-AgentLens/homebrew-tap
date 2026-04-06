cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.433"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.433/agentshield_0.2.433_darwin_amd64.tar.gz"
      sha256 "480c8345e32fbe17ee6e88044d8248e175ad593aca0e31569310a01d3079fd30"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.433/agentshield_0.2.433_darwin_arm64.tar.gz"
      sha256 "7482890161492c080df9cb9a4df03d347b397b3c9d3cf503656f8d240fd2a4b9"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.433/agentshield_0.2.433_linux_amd64.tar.gz"
      sha256 "c3b994a1248e5ed4a37c53c408b876315094a5e944c4824a00ec226218339820"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.433/agentshield_0.2.433_linux_arm64.tar.gz"
      sha256 "5546dcaad363a2e8ebe3f52586dd6f444f9eacd075ce444f9c3719eaf3b63bf2"
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
