cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1549"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1549/agentshield_0.2.1549_darwin_amd64.tar.gz"
      sha256 "30394d2da63b98ac0f57b49b6f6e561b391ca82b2b599b7511bc2f6ded2e80a9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1549/agentshield_0.2.1549_darwin_arm64.tar.gz"
      sha256 "bd71611fce90d2343c4bc9f87827def1e15046a6fb48dc7d9bf14b1c642f780d"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1549/agentshield_0.2.1549_linux_amd64.tar.gz"
      sha256 "2e315ec956c8de0802aed650ecd7f7659b714715f758c30dd92cb2a976e87988"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1549/agentshield_0.2.1549_linux_arm64.tar.gz"
      sha256 "b3200b84bbd59243751535939cfd9422f977920a2d1c63d5d219efb9dfe498eb"
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
