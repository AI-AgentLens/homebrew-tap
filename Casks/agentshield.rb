cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1661"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1661/agentshield_0.2.1661_darwin_amd64.tar.gz"
      sha256 "3f6315472ea58a523d81f15b4d372f6ad196f19790a2f6f3c3c584a374d7893a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1661/agentshield_0.2.1661_darwin_arm64.tar.gz"
      sha256 "da84faf0701bc50d7037de7921cb24b51ab924a0724a3549fafbfcb949ae167a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1661/agentshield_0.2.1661_linux_amd64.tar.gz"
      sha256 "50413daeeaa58c79ead896038791b61e9c70855bc88736a63ada157075ddf7ea"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1661/agentshield_0.2.1661_linux_arm64.tar.gz"
      sha256 "7d6bb15799408d15a1ec649f3b551849a1e6b6aed2474c346b2bdc47e790e81c"
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
