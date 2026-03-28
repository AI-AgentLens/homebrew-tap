cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.153"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.153/agentshield_0.2.153_darwin_amd64.tar.gz"
      sha256 "5d8a90bd4f69939eaa07c3f5572d640f3b203df688bef24a97b60bf45c30d7cc"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.153/agentshield_0.2.153_darwin_arm64.tar.gz"
      sha256 "e42e119603c5f7e50873e4b63106cc8329256f66fd1618f589864ce58cccf265"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.153/agentshield_0.2.153_linux_amd64.tar.gz"
      sha256 "282ef2be99529edf234b7ec067770c4394b08157b0b8138503a8436aced4078e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.153/agentshield_0.2.153_linux_arm64.tar.gz"
      sha256 "cd788fc6fa15bc69f39b593e7aac81d0ff3561a11d6a48355db09c1cbaab685d"
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
