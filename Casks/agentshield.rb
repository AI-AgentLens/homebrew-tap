cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.121"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.121/agentshield_0.2.121_darwin_amd64.tar.gz"
      sha256 "ab94a2021b2dae95d04aac90c5eb7653149694535b2e7e1510c9735644668b7a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.121/agentshield_0.2.121_darwin_arm64.tar.gz"
      sha256 "d379a7ced46f4caef50d919205fe3bbd34739a6ff1a8fec73795c8357122b644"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.121/agentshield_0.2.121_linux_amd64.tar.gz"
      sha256 "264e7108be42aa45d6f7e5c090b9a9765269eaab2765ad1bb699d9b7281e4aba"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.121/agentshield_0.2.121_linux_arm64.tar.gz"
      sha256 "4d4b59af0879f0f60a2be7b47ce6975360999ed0c6c00bc25c31206a517fedf0"
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
