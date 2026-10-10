cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2388"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2388/agentshield_0.2.2388_darwin_amd64.tar.gz"
      sha256 "600a29d9665459c5e9ad97d53b8d4442f39a712f216d8f812cd5467234a6eece"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2388/agentshield_0.2.2388_darwin_arm64.tar.gz"
      sha256 "1afc57999e6034d58c5274371e99c745890e1c4ce386e9d78745f04e214b9150"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2388/agentshield_0.2.2388_linux_amd64.tar.gz"
      sha256 "4ed793f5db840439a9ef6879454e25668e99aa7d0b699f3d268b01f5fd3159ae"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2388/agentshield_0.2.2388_linux_arm64.tar.gz"
      sha256 "a7a1cfc1f07c207c8c5a86327cfc9d690a16712f718a92da2e6bf767e463add9"
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
