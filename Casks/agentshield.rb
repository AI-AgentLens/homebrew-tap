cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2016"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2016/agentshield_0.2.2016_darwin_amd64.tar.gz"
      sha256 "404a0138e7f8609e6bcae45a45bc0ec54b5d267f22e35f7cf23557bddde6a182"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2016/agentshield_0.2.2016_darwin_arm64.tar.gz"
      sha256 "357799d2477785645cb3a1088a1afa415d63beb7ee4f7bbc096e02a77b83584d"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2016/agentshield_0.2.2016_linux_amd64.tar.gz"
      sha256 "0da8612fb12ab563676ca000a2524a8d1758b4bb93caf9aad99b3fd068f16d91"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2016/agentshield_0.2.2016_linux_arm64.tar.gz"
      sha256 "d9164e0bacccf30b8b3b5019a1f21e9ebdd55a9950a0b8d7be24f51386d945ad"
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
