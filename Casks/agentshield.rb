cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.863"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.863/agentshield_0.2.863_darwin_amd64.tar.gz"
      sha256 "71bbb2b6b3f89d5ecbc33432f2da4c09fb1b9dfe0ad07bb2d9634ecd0dababad"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.863/agentshield_0.2.863_darwin_arm64.tar.gz"
      sha256 "8eee927e4f57c9357d63bb3e5e83577d732515b0071e910bffc989f849b46e3d"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.863/agentshield_0.2.863_linux_amd64.tar.gz"
      sha256 "b50afafeb2dcd0f77d81084e81e0cf3193cc29a53eba545be2bdbaf1b8d55ff0"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.863/agentshield_0.2.863_linux_arm64.tar.gz"
      sha256 "5a750a252b4284d0b7447af88a03bd43d8de8ab679b4a335fdae6e42d3135089"
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
