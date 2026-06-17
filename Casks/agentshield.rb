cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1349"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1349/agentshield_0.2.1349_darwin_amd64.tar.gz"
      sha256 "117913a8b3a6dc215b34ba512c5678b50da973e672e53aa48fc41369fb091435"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1349/agentshield_0.2.1349_darwin_arm64.tar.gz"
      sha256 "d6d183c1eb6308bf3b6363faa4c47d421467dede837582a5505cef4d91824668"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1349/agentshield_0.2.1349_linux_amd64.tar.gz"
      sha256 "715acd3ab5f00d86e11fdcb889795c91914836ad88fd9c25205bd42db150d534"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1349/agentshield_0.2.1349_linux_arm64.tar.gz"
      sha256 "074ae64153e1619761e687cb631afa7821e57bf4583512007901856991075072"
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
