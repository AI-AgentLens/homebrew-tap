cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1576"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1576/agentshield_0.2.1576_darwin_amd64.tar.gz"
      sha256 "ba7f2e5b7c32e313dcd5674deb06d64f389d838a4120f43bb154a188f9452c2a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1576/agentshield_0.2.1576_darwin_arm64.tar.gz"
      sha256 "d75aa89301f0837ebddfd672eec2a4fe27eacf1a175dfc271e0ad017bfdea332"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1576/agentshield_0.2.1576_linux_amd64.tar.gz"
      sha256 "e4ad9b09045e88aa96e5144e133fe51d3545ca8980cb1968e4b28895f0352ac8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1576/agentshield_0.2.1576_linux_arm64.tar.gz"
      sha256 "faafb5dd44ba29a6b1badac14af1e2dc39de3da7b6f98f041a2dfb4ad44ce7ad"
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
