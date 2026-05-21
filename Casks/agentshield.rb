cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1061"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1061/agentshield_0.2.1061_darwin_amd64.tar.gz"
      sha256 "6edc9201b70456aa1fb8303d40a9d2257709ee562ddf59e1aaaceeb02abb3682"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1061/agentshield_0.2.1061_darwin_arm64.tar.gz"
      sha256 "f2b984a91460fa8d630e8a136d7d07705e1f4dcdd00340993804735bb4e6504b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1061/agentshield_0.2.1061_linux_amd64.tar.gz"
      sha256 "08f81a2c6ddc4fd277a0796aa677d8588f6b7a5ad643064a30b1513e3e3e91ae"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1061/agentshield_0.2.1061_linux_arm64.tar.gz"
      sha256 "ce5e97af96f0f0fa678fbbe5efbc5e7e51a5aaf044892ca6c24bc8325675ca51"
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
