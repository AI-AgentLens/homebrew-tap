cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.573"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.573/agentshield_0.2.573_darwin_amd64.tar.gz"
      sha256 "d71328ba8a7bbd0fdd147aab5a6c0b506c414910374c2e51cf18a2e80f82385b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.573/agentshield_0.2.573_darwin_arm64.tar.gz"
      sha256 "b67fe44da1c2ab99dc97df32c5126899360b37e0b4c013ea63e7e29d89ccacf9"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.573/agentshield_0.2.573_linux_amd64.tar.gz"
      sha256 "e4dc981df378d465cd8e86f31b781211f76c02da86445d0a4a8faa20e37f4248"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.573/agentshield_0.2.573_linux_arm64.tar.gz"
      sha256 "5bd354d7c1af59b906e979b33e38c08d45f4213a6509d4b2040030dc3af97ced"
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
