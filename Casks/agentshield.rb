cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.326"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.326/agentshield_0.2.326_darwin_amd64.tar.gz"
      sha256 "f5f61a5fa33186da30c77f03fc8e2a0478e73e43170aad350ec63b7e83d4c3de"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.326/agentshield_0.2.326_darwin_arm64.tar.gz"
      sha256 "88cfac7efa156f61f441470b0691e0c45edd138235fa32b76cefc068a5870c22"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.326/agentshield_0.2.326_linux_amd64.tar.gz"
      sha256 "62cd995feb6c33c193eb295a8bdf753fa1edd29a64311d8052781ffabe5d95c4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.326/agentshield_0.2.326_linux_arm64.tar.gz"
      sha256 "358c09841f006935e065ad12d0afd82d2564d44e3bf3414a411da7fc376f39f9"
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
