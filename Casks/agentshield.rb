cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.425"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.425/agentshield_0.2.425_darwin_amd64.tar.gz"
      sha256 "04168fe3f755cd7b5141208595482bec24a511534a9ec630b4b8ec88b060a13d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.425/agentshield_0.2.425_darwin_arm64.tar.gz"
      sha256 "698edcc4454743584fecd38d79392d7d25b019e81260dc4df0d2f0bca904ca72"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.425/agentshield_0.2.425_linux_amd64.tar.gz"
      sha256 "53b53124d87004d86fd0945813fac82577bbdb63dd424e19a17b10e869975bb6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.425/agentshield_0.2.425_linux_arm64.tar.gz"
      sha256 "a260ddb7cf2b4247e76b886a434a37ac8c515607f69701e8d75adbe3e54e1d13"
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
