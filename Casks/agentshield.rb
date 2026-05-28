cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1133"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1133/agentshield_0.2.1133_darwin_amd64.tar.gz"
      sha256 "8df6855c08fd161ba011166a708f46d751a9765e134e55ea29374a4a80c4a953"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1133/agentshield_0.2.1133_darwin_arm64.tar.gz"
      sha256 "4dca5dbb3ee3f05e3a9216a10f644ef157ddf6100909cbb45d3592d02039f2c0"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1133/agentshield_0.2.1133_linux_amd64.tar.gz"
      sha256 "f7d0c3a72d56858e0d2ddcee14bedbc9bb0b0796ce696af29cf3b67a30fe3f41"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1133/agentshield_0.2.1133_linux_arm64.tar.gz"
      sha256 "8685c4a8f3b9a67599ab1449a9e2f9c58b6dfd6f36e7058d4db3e778879683e0"
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
