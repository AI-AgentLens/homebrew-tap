cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1825"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1825/agentshield_0.2.1825_darwin_amd64.tar.gz"
      sha256 "f07c2ddf21d91ee5637ae9d6f3618553d67f90c54cac7a7349d921fb2d914ff2"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1825/agentshield_0.2.1825_darwin_arm64.tar.gz"
      sha256 "cd564ac8d6d305e051e027fe07a9be3d29dbc2b083ca3d419ec373bbf1cb4568"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1825/agentshield_0.2.1825_linux_amd64.tar.gz"
      sha256 "4fa224bad8ffeff6401f428f584ea68a2c687aa75dec6a7a8df2e77835ca4504"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1825/agentshield_0.2.1825_linux_arm64.tar.gz"
      sha256 "6fb6bd9e96d4e2e98279a2e7a55ef32ec0ef506b6831236db966083f63b67119"
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
