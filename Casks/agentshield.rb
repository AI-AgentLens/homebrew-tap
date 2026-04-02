cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.306"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.306/agentshield_0.2.306_darwin_amd64.tar.gz"
      sha256 "e1e6d14a635efc7eb4677c2db3c9c15ca44fa3b31bf462402c9c7554bde3382c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.306/agentshield_0.2.306_darwin_arm64.tar.gz"
      sha256 "f1e85537bc4f4c5c500f2c78447a0c1b6a3e02b711cce3e785cb3cdbf83e6763"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.306/agentshield_0.2.306_linux_amd64.tar.gz"
      sha256 "26866ea8928d7e84cf3902aa10e385f6dd01ef093b276f31cfce2d1d3a309da7"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.306/agentshield_0.2.306_linux_arm64.tar.gz"
      sha256 "5ece9c74c6bc5660aadc143ec89984658d9a932e8088753a4c9776a4dd79fe74"
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
