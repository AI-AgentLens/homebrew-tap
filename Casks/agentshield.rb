cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2035"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2035/agentshield_0.2.2035_darwin_amd64.tar.gz"
      sha256 "1cbbd7f39327896e2f29015168c709ae8803eeea8d05799d6e18478b86b70ffa"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2035/agentshield_0.2.2035_darwin_arm64.tar.gz"
      sha256 "903b9ba03add052133a3c80943f115a429af15a1ce556df81e1f27c696fdd759"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2035/agentshield_0.2.2035_linux_amd64.tar.gz"
      sha256 "f93b953ada880209998de6835637f4d1ef7277043008bf825c741c13157af0ba"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2035/agentshield_0.2.2035_linux_arm64.tar.gz"
      sha256 "f196dcd63f0df869717006d9a8e178a94d5cd4ac1ae58c97b3da584df851f1cd"
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
