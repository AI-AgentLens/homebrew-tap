cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2516"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2516/agentshield_0.2.2516_darwin_amd64.tar.gz"
      sha256 "75975b143badd75abb61a01423c4eec92476cd1e8f9395b689eac4865c794504"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2516/agentshield_0.2.2516_darwin_arm64.tar.gz"
      sha256 "6eafaf9f8d1574be9cb3e116506a64e3dcf08e03b9c9f52779edc59bd2e2b438"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2516/agentshield_0.2.2516_linux_amd64.tar.gz"
      sha256 "aac1f7614155c50a361d5bad02fefffc883f0019464d972720837b1c7deffc2f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2516/agentshield_0.2.2516_linux_arm64.tar.gz"
      sha256 "e9d274fdfabbba4768696a3e0053988a9f2ddc2e89fd864fbf080a8fbe00072b"
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
