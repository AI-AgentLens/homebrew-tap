cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2268"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2268/agentshield_0.2.2268_darwin_amd64.tar.gz"
      sha256 "d726dbc2cc01d2c2af201c4488c168acca5c16963218961500440eca279eb87c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2268/agentshield_0.2.2268_darwin_arm64.tar.gz"
      sha256 "02731546df14d569118e38adb21c24c2d4664f2c2042a69a2067b5716b302073"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2268/agentshield_0.2.2268_linux_amd64.tar.gz"
      sha256 "c0b1c8e6cee0f79102516d167a907549358f860512dc99cf9c0160f4673270c2"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2268/agentshield_0.2.2268_linux_arm64.tar.gz"
      sha256 "bdcef24f2f94b809daf0550f7f9211e50dfd3dc099d07092a754a294a08481e8"
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
