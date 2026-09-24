cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2240"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2240/agentshield_0.2.2240_darwin_amd64.tar.gz"
      sha256 "e43dce0ef7c7a69b5386d00ad4f52739859ae20dcfac908ca2e0c1843b86057f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2240/agentshield_0.2.2240_darwin_arm64.tar.gz"
      sha256 "1bba35662b9304b94942f08a59db34832da51498177007d13495364c05455378"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2240/agentshield_0.2.2240_linux_amd64.tar.gz"
      sha256 "2bd207d5b184c989fc78a495f7900ab024527db1e468778cc0c4a9d0136b4915"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2240/agentshield_0.2.2240_linux_arm64.tar.gz"
      sha256 "4aec527d0fb220cb917ff4e0c61c497792997245e8f1eb98a039de6cb63f3f39"
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
