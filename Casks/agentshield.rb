cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.521"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.521/agentshield_0.2.521_darwin_amd64.tar.gz"
      sha256 "a5931f809d3210a0ce51fedc4866e54d2b08b22c4feeeb65133bcd08a7d15143"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.521/agentshield_0.2.521_darwin_arm64.tar.gz"
      sha256 "17bae2db62f17a100f5e4a0ce5071b3f6b637140a9975e0d20dfbae72a214790"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.521/agentshield_0.2.521_linux_amd64.tar.gz"
      sha256 "f9753d4a418bfef4714ddeac87b0c26358aaf71910841cf3908475646e5e4805"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.521/agentshield_0.2.521_linux_arm64.tar.gz"
      sha256 "1be6261f1463a01a029116e2ae74574586c24d4eb7cce985c448127cabea39f0"
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
