cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1147"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1147/agentshield_0.2.1147_darwin_amd64.tar.gz"
      sha256 "01c0150026c70d6924c3207b48cedd25a3ffa50c289f76c20168de50974d6582"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1147/agentshield_0.2.1147_darwin_arm64.tar.gz"
      sha256 "374df33a04ba9939f657b2a735396e4c5d5a0a6ec66945bc657711ce662312a5"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1147/agentshield_0.2.1147_linux_amd64.tar.gz"
      sha256 "b93c9c60446da69bf03d87cc8c31ccdc156668bcbc3e1c7ff9481228fd424137"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1147/agentshield_0.2.1147_linux_arm64.tar.gz"
      sha256 "39857bdad999e99fd97eea3cb9ce62f272a25e84ed0751497d88574853e8e3a6"
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
