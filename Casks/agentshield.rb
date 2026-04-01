cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.275"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.275/agentshield_0.2.275_darwin_amd64.tar.gz"
      sha256 "0b9e696109344b126b45695807fd703a7c734a223998dfa554e1e5af7095c139"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.275/agentshield_0.2.275_darwin_arm64.tar.gz"
      sha256 "30ffd028aae405482532ab829e66b8b978579f5ddfab920d889d814901e12bd2"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.275/agentshield_0.2.275_linux_amd64.tar.gz"
      sha256 "335d958a68fc59358f93200c19b82bc00004838567e2cc10a902de4b3c57de2f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.275/agentshield_0.2.275_linux_arm64.tar.gz"
      sha256 "7c6c6aaae4cf1b8a08c3a8ae6f3873b3a0e13c03c2c36e9e967d8fa2c5213771"
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
