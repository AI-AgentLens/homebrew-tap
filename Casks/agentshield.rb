cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1939"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1939/agentshield_0.2.1939_darwin_amd64.tar.gz"
      sha256 "49bb2dde0fd1e0e37cd4c550cd08374e24b89691e55456f08f3d7bb6ee8402c0"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1939/agentshield_0.2.1939_darwin_arm64.tar.gz"
      sha256 "94f26a587052996b158c7fe3dc8217bdc7a59986e45b823b47d2dabeafe07180"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1939/agentshield_0.2.1939_linux_amd64.tar.gz"
      sha256 "90c44e56da7acf684b581e6213b32d2b74f4385e73d92a281921d7687c825e63"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1939/agentshield_0.2.1939_linux_arm64.tar.gz"
      sha256 "3687684d946e92125a56f64bdfe156596364f8a446c5553e31241efc5bf4a010"
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
