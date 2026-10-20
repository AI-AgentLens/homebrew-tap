cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2477"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2477/agentshield_0.2.2477_darwin_amd64.tar.gz"
      sha256 "af7fd754581606080d2833a67b846331a51a20347737489caabfe8c98d12b878"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2477/agentshield_0.2.2477_darwin_arm64.tar.gz"
      sha256 "94e6577783ffe5c1beeabba24ce77ef1495bdb9f46b9c9a10468efe6bb3c5f0f"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2477/agentshield_0.2.2477_linux_amd64.tar.gz"
      sha256 "4f4381b1bc7799555d46d35da0469a9a428394fcc88395938a636b1359e8cf66"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2477/agentshield_0.2.2477_linux_arm64.tar.gz"
      sha256 "0150938ea2a94521e8a209b5756d5b6914845851d64b075886970ad6759f9b73"
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
