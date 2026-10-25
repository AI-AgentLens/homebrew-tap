cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2525"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2525/agentshield_0.2.2525_darwin_amd64.tar.gz"
      sha256 "51a220a76872201a0d30a03720409db9ccc6041fef2a7f7e02e4cf13a18c67f5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2525/agentshield_0.2.2525_darwin_arm64.tar.gz"
      sha256 "ed33601fa7934a7c7a120bd4e13a255c39be2e3eb220a1aae0ebcaf6b574ae1f"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2525/agentshield_0.2.2525_linux_amd64.tar.gz"
      sha256 "da750fbf72adb65389f08137e6ee16f8529f2453483b1f75c63214803cd07a87"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2525/agentshield_0.2.2525_linux_arm64.tar.gz"
      sha256 "2e360607b0c0d8872b45d462700037922fc8a95dc6e2f3f25b28f7566049a107"
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
