cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.170"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.170/agentshield_0.2.170_darwin_amd64.tar.gz"
      sha256 "49636121309500cfc40b2abbf00848229f8e954dd6dba424a853efdb20fcdcbb"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.170/agentshield_0.2.170_darwin_arm64.tar.gz"
      sha256 "99be9f2aad3beb4a6015fe5e3e35e02e262bd83b5cb031b00303474132e7dbd7"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.170/agentshield_0.2.170_linux_amd64.tar.gz"
      sha256 "a772b07ab5e5b609ec9c167f3b9a0cc28569ced852ef042b24e885fc95c354c8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.170/agentshield_0.2.170_linux_arm64.tar.gz"
      sha256 "2cc20c73833a12f893017e53a11dd754f4c338926efc24bacc8fab6dfc8b06be"
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
