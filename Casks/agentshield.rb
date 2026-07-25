cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1728"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1728/agentshield_0.2.1728_darwin_amd64.tar.gz"
      sha256 "63bbbeb6d415e59e352b8da9b4ca4ed41283686ab38b5fc732964f006c1b2d15"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1728/agentshield_0.2.1728_darwin_arm64.tar.gz"
      sha256 "9024b45ad5a7b503f69c976802fd8a7a9eaa1f220d961a826f88ebdd61212ae8"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1728/agentshield_0.2.1728_linux_amd64.tar.gz"
      sha256 "0d24d02bbd6bf02dc48ce03c2ebc084ef6ff221f80d7ad63c9119161c5a2dbfb"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1728/agentshield_0.2.1728_linux_arm64.tar.gz"
      sha256 "29463930b57d5537bc8940274fbbbf807d2ca3954ee184b82ccd8c0e113b2543"
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
