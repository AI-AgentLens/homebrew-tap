cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.236"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.236/agentshield_0.2.236_darwin_amd64.tar.gz"
      sha256 "f12a8e4e402571cdc85c46772649e6680a3c69d7f902ed0298871e82489320a1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.236/agentshield_0.2.236_darwin_arm64.tar.gz"
      sha256 "d40c0dc0972c9814e3a6180d0a2a36bf804e7fef4a31c5584af2f6dbe4e78c8c"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.236/agentshield_0.2.236_linux_amd64.tar.gz"
      sha256 "1b4f77f5eeaf172068e09adddd6ad3cc53a753d866cdd10becf550480a4ea818"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.236/agentshield_0.2.236_linux_arm64.tar.gz"
      sha256 "22f04392ad20e987868878bec3ca19bddf5c3eb9011eb7fed9848cd84ab4430c"
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
