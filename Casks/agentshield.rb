cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1377"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1377/agentshield_0.2.1377_darwin_amd64.tar.gz"
      sha256 "931e8c36846148af7eef4e88ee4ef5e693df5ba253dc022627c47bdf98bad0c3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1377/agentshield_0.2.1377_darwin_arm64.tar.gz"
      sha256 "5c64f962b4ba801ad7d7ac1e15b181e40277072181fcf3edcc7ceb5d98a8fed0"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1377/agentshield_0.2.1377_linux_amd64.tar.gz"
      sha256 "0c4ce61bd84854df558a0ca165d597a981929dd80995de14ac8ad028032c5e70"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1377/agentshield_0.2.1377_linux_arm64.tar.gz"
      sha256 "052a00d4cb2399891a0351a780ae7dda5a8ed68bea47aa7217913894f29a631d"
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
