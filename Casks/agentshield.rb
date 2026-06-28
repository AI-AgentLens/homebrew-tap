cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1483"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1483/agentshield_0.2.1483_darwin_amd64.tar.gz"
      sha256 "00660a7c2b7b9b14d874e8e76587cdde65936e8f443eb2e76175830543b8daad"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1483/agentshield_0.2.1483_darwin_arm64.tar.gz"
      sha256 "f01c36cec7376ce53386a2e5145c26d55201fa164e3b0a67347087257825f4b3"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1483/agentshield_0.2.1483_linux_amd64.tar.gz"
      sha256 "608d16de687a3472ec014078145f3e8bb2449449816fb6b7e9e5a06d85915199"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1483/agentshield_0.2.1483_linux_arm64.tar.gz"
      sha256 "a71de9abad192dde61750cc707e28e8ccfeb4e8d6d359c9dddb35cd613c428c7"
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
