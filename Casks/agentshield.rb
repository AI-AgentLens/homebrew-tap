cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.824"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.824/agentshield_0.2.824_darwin_amd64.tar.gz"
      sha256 "b1ed351fd39a7b918ab837f6e4a176c0ddb1f0c24f8e18270ce6f26fb9d05683"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.824/agentshield_0.2.824_darwin_arm64.tar.gz"
      sha256 "ff83ccbef6f60f679e149889fad3748303435901f64b0b55cc1a387f6b8d4fd8"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.824/agentshield_0.2.824_linux_amd64.tar.gz"
      sha256 "c061fa86f452cd8656a5b0d70b5872d778278b720bd3d370e382477925846bab"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.824/agentshield_0.2.824_linux_arm64.tar.gz"
      sha256 "b4d4700c27ef67262c41a31ada7d05e5d1003aabcee1c1633ff05184e9a46653"
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
