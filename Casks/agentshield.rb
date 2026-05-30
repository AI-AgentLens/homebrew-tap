cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1150"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1150/agentshield_0.2.1150_darwin_amd64.tar.gz"
      sha256 "cc76c6ba8f2c92f1a21190d31fe06bd85c6db099d6d0025760f091ac2cc21762"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1150/agentshield_0.2.1150_darwin_arm64.tar.gz"
      sha256 "277fbc3f114b82c388bfa29dfbc6a3ced9cbd32530c21ac08f2fdfcb2f1ec4b1"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1150/agentshield_0.2.1150_linux_amd64.tar.gz"
      sha256 "c37353f9f3a40280776a2d78892d1aff25667a430bbd894dcbebedaa08037784"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1150/agentshield_0.2.1150_linux_arm64.tar.gz"
      sha256 "2e998e4b965f2ded585b8066a5b624d2bccb85856cd188d2b9e01172a30e6353"
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
