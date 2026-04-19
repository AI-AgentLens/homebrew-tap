cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.657"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.657/agentshield_0.2.657_darwin_amd64.tar.gz"
      sha256 "a7e503eaf1167ab5e611623e4848ec17ddd961910836e781f01ee72378493f0e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.657/agentshield_0.2.657_darwin_arm64.tar.gz"
      sha256 "33ed0bb486ebdfbe0020f97da5d97a400a8ea1c8f9f33fee5393a7b48550f7b7"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.657/agentshield_0.2.657_linux_amd64.tar.gz"
      sha256 "18d50f4fdba9d33ab2f85ded4788ac6e720c18d880c5cbd9f0754e924a6adc0e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.657/agentshield_0.2.657_linux_arm64.tar.gz"
      sha256 "76d99964c367d1eb5b37dc08242f14919dbc10431a6a638211f81e931da5af90"
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
