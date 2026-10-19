cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2464"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2464/agentshield_0.2.2464_darwin_amd64.tar.gz"
      sha256 "c8703e9ba4ed9bf6074eef1c38f9bf919fae480a08bb64ed0f7570c2b7a91aba"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2464/agentshield_0.2.2464_darwin_arm64.tar.gz"
      sha256 "14f39c94684bd4881607bd0057816ee2d59e9dea3dfc6cff41fcdddb6145320b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2464/agentshield_0.2.2464_linux_amd64.tar.gz"
      sha256 "17453a34084e340156d91a0ab55a29377765aaa20bbeb6a0facb0202f6742694"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2464/agentshield_0.2.2464_linux_arm64.tar.gz"
      sha256 "15b35b9dfbd2e09318fd00fd9942aa99290c57bf8a2b246da36e7f7c591954a3"
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
