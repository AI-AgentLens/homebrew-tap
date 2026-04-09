cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.514"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.514/agentshield_0.2.514_darwin_amd64.tar.gz"
      sha256 "64a0da14e918fc57cdf607ea83897fa99845c1d2f321769f7ff9c78eaf0a1462"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.514/agentshield_0.2.514_darwin_arm64.tar.gz"
      sha256 "6ed4db0c4d0a9632d0765e6e3cfd8be371ad4b903d4f2e5293eab81de050cef7"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.514/agentshield_0.2.514_linux_amd64.tar.gz"
      sha256 "ae5e5391487893b5f9bcf9bf44501aabebb340faa89ce71915be1211b2189ff3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.514/agentshield_0.2.514_linux_arm64.tar.gz"
      sha256 "e8eecfe382d9b34083a1b83b7ac1817a7e631856c67e8dad286ea1bada7b2fe0"
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
