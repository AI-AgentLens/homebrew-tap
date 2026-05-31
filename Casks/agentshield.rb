cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1163"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1163/agentshield_0.2.1163_darwin_amd64.tar.gz"
      sha256 "38c785f7c99f29aad9363037e56697fe14c87222fda4c8f3d51df19066295bfb"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1163/agentshield_0.2.1163_darwin_arm64.tar.gz"
      sha256 "c727289a39f767e175892e1cc5ff621f996e9f2cd6981a9aa83f57862a468ec6"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1163/agentshield_0.2.1163_linux_amd64.tar.gz"
      sha256 "2c545f0a0a9955cf1fc02af447df00e617bd5039b8b345fd96ea5a46361f7645"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1163/agentshield_0.2.1163_linux_arm64.tar.gz"
      sha256 "e0cf5d9b4e7c0b9d63ba07732fe75fdb0e18edccb8c4b46c8ea2b3b4cbcd058f"
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
