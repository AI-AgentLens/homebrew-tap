cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.497"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.497/agentshield_0.2.497_darwin_amd64.tar.gz"
      sha256 "ba68a0718f20f42dc1fd9515ce31046dcc34cf3ae1babe2adeab7ed80328e2fb"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.497/agentshield_0.2.497_darwin_arm64.tar.gz"
      sha256 "d91720d809ce0b367c76d0f37b097e3af234ed5099de07f8be59079e87e5baf0"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.497/agentshield_0.2.497_linux_amd64.tar.gz"
      sha256 "113500c99a209047749a8bdc54dbcf0f3afccbfcb46636451e10e388784f0921"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.497/agentshield_0.2.497_linux_arm64.tar.gz"
      sha256 "dd0dd7ef4cc084856bdbf16aaa5100a66d465c089d61648711da8de82eb22f28"
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
