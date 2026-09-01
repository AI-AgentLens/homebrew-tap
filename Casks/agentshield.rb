cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2017"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2017/agentshield_0.2.2017_darwin_amd64.tar.gz"
      sha256 "bba915c2032c72d0cbc2fa2e5052266dc012d5231edb9b2408d8c96c97f265e5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2017/agentshield_0.2.2017_darwin_arm64.tar.gz"
      sha256 "94cb97c1ff622c2df9c57683fb2cffcfd7aca4217d302282fc317c19114824f4"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2017/agentshield_0.2.2017_linux_amd64.tar.gz"
      sha256 "ff34dc27036b98da6098fbe8502c44173b474372edd3673adbda6a63bd99bb43"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2017/agentshield_0.2.2017_linux_arm64.tar.gz"
      sha256 "3d5ce311e7328d3cf216c6a50d590056a3ed7e1cdf398908e7d52b06e0dab029"
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
