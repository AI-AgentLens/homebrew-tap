cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1449"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1449/agentshield_0.2.1449_darwin_amd64.tar.gz"
      sha256 "42d684e0522e725bacb6a56befb0c721ea9b4a996ff80a18bf990ead4aee3ee1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1449/agentshield_0.2.1449_darwin_arm64.tar.gz"
      sha256 "e8314105d09946730114555618545f44687aa51dc3c8c85988d4a2e5d366f91a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1449/agentshield_0.2.1449_linux_amd64.tar.gz"
      sha256 "595137f93c7185b6aa2f422cb44b2fc5770f8bcecab641d4a57a5069045e54ec"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1449/agentshield_0.2.1449_linux_arm64.tar.gz"
      sha256 "24f587b9621d54586d4903e5e6200512a7305e021d42435842b79d13d8eaef12"
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
