cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.525"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.525/agentshield_0.2.525_darwin_amd64.tar.gz"
      sha256 "d277bb394293b112de061c36ddad880c228a5c241e8df91a7209d021178bd48d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.525/agentshield_0.2.525_darwin_arm64.tar.gz"
      sha256 "2b9376fcf00b77d7bef52312e81c2cf6ace7854df4b77ca1f77aece40e04f181"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.525/agentshield_0.2.525_linux_amd64.tar.gz"
      sha256 "a881dffa02d58a8a0367e0fa19a5493749e3e4bfbfdd221b5094a67709a50aac"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.525/agentshield_0.2.525_linux_arm64.tar.gz"
      sha256 "765f1ee15574ac571e1c68bf801a3e0ae4257fcb0b636228af1ba2a5672a548e"
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
