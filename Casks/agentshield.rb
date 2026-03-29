cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.207"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.207/agentshield_0.2.207_darwin_amd64.tar.gz"
      sha256 "515fcdaf780e4d7176a00c7665a036a04b2915835e4dc28b6ce24c5de5403bd9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.207/agentshield_0.2.207_darwin_arm64.tar.gz"
      sha256 "cc5f52766db49eb08a14c80775f8928ee89b4b9e334579910b98bc253a7d505c"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.207/agentshield_0.2.207_linux_amd64.tar.gz"
      sha256 "26c67eb4fb53b0d04a3426f37d3852fbc8f92dc89605008dfc12e9966d3db048"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.207/agentshield_0.2.207_linux_arm64.tar.gz"
      sha256 "c172d3102de8ce4fedbf0ca8320e0bc9ec4dcf19ee0f3defe2594375eb5fe4b7"
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
