cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2191"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2191/agentshield_0.2.2191_darwin_amd64.tar.gz"
      sha256 "2b6003d0097e107864d705bcb621a81f4f6a2ac0d220090b1d71f5af183bf246"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2191/agentshield_0.2.2191_darwin_arm64.tar.gz"
      sha256 "e5c9fd8f997e33815bbab7f86e972341a9e4ded572d62161d682537a91ccdf3b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2191/agentshield_0.2.2191_linux_amd64.tar.gz"
      sha256 "cdbfd1dcc2a1847106e5ae8a29b77a057f436149fabfccbbaf747201ca54d420"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2191/agentshield_0.2.2191_linux_arm64.tar.gz"
      sha256 "428397cb9a287304adb0dbd76812b3cff0ea8c812e638c62acc0625cbff3b649"
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
