cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1524"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1524/agentshield_0.2.1524_darwin_amd64.tar.gz"
      sha256 "9f026a1e088279b36717df9c9a3e8d7999d81ece747d30259f75b42392174fdc"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1524/agentshield_0.2.1524_darwin_arm64.tar.gz"
      sha256 "f53a966fa30e2c95e264d20aac6b03f3ce3804d9e1c23e61b1dc859327ca2073"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1524/agentshield_0.2.1524_linux_amd64.tar.gz"
      sha256 "b72723d0b1c28995fd131bfcec505a0c85efa70e99ddb723dec2cec32fe96618"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1524/agentshield_0.2.1524_linux_arm64.tar.gz"
      sha256 "a1b5ff18d827a6c65f0f5ac0ba50b8624eb4793fa9232edaae75817043e7f1cb"
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
