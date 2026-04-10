cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.528"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.528/agentshield_0.2.528_darwin_amd64.tar.gz"
      sha256 "95efc483501493f242fea8311d5ea15959a6278587d3d5e3b9295f538857e4d1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.528/agentshield_0.2.528_darwin_arm64.tar.gz"
      sha256 "82e7ed8e8dec65a80d8fd63aea12a85cfb397e17b31e3c4becc2e2abc9b567fa"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.528/agentshield_0.2.528_linux_amd64.tar.gz"
      sha256 "a908080d15797b1337db03f02f1f346ee92ee4a3fafe3c144677032d06435740"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.528/agentshield_0.2.528_linux_arm64.tar.gz"
      sha256 "b09b884c6a263cc91ebdd0fef8d01c112a47d8be6317288570bb56d222c3cebe"
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
