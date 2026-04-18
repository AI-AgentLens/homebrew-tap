cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.638"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.638/agentshield_0.2.638_darwin_amd64.tar.gz"
      sha256 "a1e75f0a4ded7bb4feed155fc255c4c18b90e989e70c2d8835bd86ecd4719303"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.638/agentshield_0.2.638_darwin_arm64.tar.gz"
      sha256 "bc0accea7c35ed9c6a7c7620127200e1d8879d9c23d4411f193ada66ca8320df"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.638/agentshield_0.2.638_linux_amd64.tar.gz"
      sha256 "343f4b2505aa0befedcf5ea95db4715b53990019b3e745cc458c45ba78be710b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.638/agentshield_0.2.638_linux_arm64.tar.gz"
      sha256 "ded3be49be1bc4c5a23fada6bc0e7e48f53f010d84240cb96896db73f32c4ab4"
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
