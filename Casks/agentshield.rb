cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.249"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.249/agentshield_0.2.249_darwin_amd64.tar.gz"
      sha256 "85c3c9ba05f1fce071d92909ea4971e0f55a0ed67c6774bfb4eda3a84d3f0edb"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.249/agentshield_0.2.249_darwin_arm64.tar.gz"
      sha256 "1d1aad549a0b6404ff641a8324ef420014ad8b5d2fa63f4304b1c438820c0bce"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.249/agentshield_0.2.249_linux_amd64.tar.gz"
      sha256 "05f89f5d0ad344fb7d89465376c40f05a223b5b62db22b306b2278cb4a6f3ab9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.249/agentshield_0.2.249_linux_arm64.tar.gz"
      sha256 "d731e075c6c14c559eecc71b2abc2b274ccf6c27c91eadc3fcd884d6e79d7bc1"
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
