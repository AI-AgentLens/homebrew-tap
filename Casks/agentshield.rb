cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1563"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1563/agentshield_0.2.1563_darwin_amd64.tar.gz"
      sha256 "df70c927b8f0edbbc0e8767181fb0528881940432be81e4d91a191d4e55a58c2"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1563/agentshield_0.2.1563_darwin_arm64.tar.gz"
      sha256 "184d0e13cd581f76e910db5b76e2636cdd5087f7d778030da3c06ac3914daa07"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1563/agentshield_0.2.1563_linux_amd64.tar.gz"
      sha256 "d6db6ca5cf60f2d6cdeb98cb2f4aa615085523332d5e4510380b9483de846465"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1563/agentshield_0.2.1563_linux_arm64.tar.gz"
      sha256 "1929d151a5f5f36032fb711fec4ae8eb9eef9e6aee8cd372a9fc32a1488fb0e1"
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
