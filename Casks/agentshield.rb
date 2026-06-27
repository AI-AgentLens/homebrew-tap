cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1468"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1468/agentshield_0.2.1468_darwin_amd64.tar.gz"
      sha256 "2caf5e3bb1a24356b6f7b168b01a9ef930948519dab37f7c608886a85bc5d196"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1468/agentshield_0.2.1468_darwin_arm64.tar.gz"
      sha256 "b98809ddd510d9c2fd69642d15b271b9dfdec942ed4804876f3f57cb583d7b49"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1468/agentshield_0.2.1468_linux_amd64.tar.gz"
      sha256 "85c3536a346f2368de248b267e7386b7b794e9e8d24649fcc97ee34e6074ab38"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1468/agentshield_0.2.1468_linux_arm64.tar.gz"
      sha256 "bcc3a79f8068cf3d1cdefb1bc483a8daec1559a103649fa968dd137c83b56db8"
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
