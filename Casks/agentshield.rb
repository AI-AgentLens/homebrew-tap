cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2219"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2219/agentshield_0.2.2219_darwin_amd64.tar.gz"
      sha256 "a0daa4c22dce947822ab73efc72ea3d70c20b68f0007015b47943a9957f88e21"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2219/agentshield_0.2.2219_darwin_arm64.tar.gz"
      sha256 "10b65bb4600b644db0f3a2106b5bb5ca107f9e31c9a4f96434ad04de50ccf338"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2219/agentshield_0.2.2219_linux_amd64.tar.gz"
      sha256 "c0346f11b9bb506e184f62fefd93a54fc21e6928850612d03bf449ba9cc9acb3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2219/agentshield_0.2.2219_linux_arm64.tar.gz"
      sha256 "b3c54b4f8e21756c95bcd0e3f0d420ac2d8a73816f006877cc1c9bde72f42440"
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
