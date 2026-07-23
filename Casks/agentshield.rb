cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1714"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1714/agentshield_0.2.1714_darwin_amd64.tar.gz"
      sha256 "5a1d9ea9d588bfd64f4472886cb0c3f1a5724585f958ffcbdc2adfed1a5f8544"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1714/agentshield_0.2.1714_darwin_arm64.tar.gz"
      sha256 "d68a6a41d70b1fdfebec918b11683a4dea17bfb2efa212cdbe634a4c78fb4fe2"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1714/agentshield_0.2.1714_linux_amd64.tar.gz"
      sha256 "a4d73eb695a28a3977758be6559b266247c11495e3bf67c4dbc6114b3d23788b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1714/agentshield_0.2.1714_linux_arm64.tar.gz"
      sha256 "a97b5378f73f180634f546c04e8701029ae763d462536eb4eebd0abeba0593b6"
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
