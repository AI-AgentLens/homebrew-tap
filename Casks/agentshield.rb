cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1669"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1669/agentshield_0.2.1669_darwin_amd64.tar.gz"
      sha256 "5edd58eabb1a35937081ef9d9608eb343126d9be85f861ebaeae054f72f59837"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1669/agentshield_0.2.1669_darwin_arm64.tar.gz"
      sha256 "bc3c072f6f3ee742ddb84c3cfdc888f2520db4198de00ce0967d0b0fb0ba8c54"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1669/agentshield_0.2.1669_linux_amd64.tar.gz"
      sha256 "f01f3120c6ba85de620e1b131cfa4b50d0554a0f75c160557f2824ac09701cb7"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1669/agentshield_0.2.1669_linux_arm64.tar.gz"
      sha256 "bc3cb6e1935544807811dcdd751ae41818b075ac9fd723a7f9f2dea4678c2bfe"
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
