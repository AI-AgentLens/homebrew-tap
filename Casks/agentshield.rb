cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2092"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2092/agentshield_0.2.2092_darwin_amd64.tar.gz"
      sha256 "0f8423abb61ef752e9dd43c5db792835403730a489d2417a6dca0d968cd4530d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2092/agentshield_0.2.2092_darwin_arm64.tar.gz"
      sha256 "d235aafab94cef6dbe8932267f661c99725d2f5652c0d224a4aec462b0e34131"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2092/agentshield_0.2.2092_linux_amd64.tar.gz"
      sha256 "8c977d63ea64b5732ac244d1f529a4cf1ada83305271d21d065de31e1af0a45f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2092/agentshield_0.2.2092_linux_arm64.tar.gz"
      sha256 "8862bb298195887700b56670e134d39e35c33cd99dfff35e15d88fddc3e44726"
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
