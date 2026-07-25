cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1724"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1724/agentshield_0.2.1724_darwin_amd64.tar.gz"
      sha256 "1177e401eb736aa1938c094c41c473f0f2dbbb02009701723ec9553d12dab1f7"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1724/agentshield_0.2.1724_darwin_arm64.tar.gz"
      sha256 "a3da50734e664b8a2df68b33baadfde50130b5e1453dbc2cc502c285532de674"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1724/agentshield_0.2.1724_linux_amd64.tar.gz"
      sha256 "9c37774971bc0e04362b01167badc5daa8c608bb53bdc420711f95c7a507ca8d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1724/agentshield_0.2.1724_linux_arm64.tar.gz"
      sha256 "7d62fc85fc7d2b0b0fead58ef7d4a42af120552741c89cc8ef9ef75e1bb6bddb"
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
