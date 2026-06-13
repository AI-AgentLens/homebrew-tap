cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1299"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1299/agentshield_0.2.1299_darwin_amd64.tar.gz"
      sha256 "f5fa7b005bfbb8851677e2e23c733d1e2f49b9048a7a5713a86d20a888bc2216"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1299/agentshield_0.2.1299_darwin_arm64.tar.gz"
      sha256 "db719ff2172d74b0695e4b82a748f7ba0b6b002cda58c31cca100aaa791bde8b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1299/agentshield_0.2.1299_linux_amd64.tar.gz"
      sha256 "22bcfe780651f72f76a86feeb0c5590d2339d13c4f0040e804ad6a17a688e9eb"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1299/agentshield_0.2.1299_linux_arm64.tar.gz"
      sha256 "604a155a1f3ac5461594c669242bb84357c9d50068357c11e68d350c76ad8c5f"
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
