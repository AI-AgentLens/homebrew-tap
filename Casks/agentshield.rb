cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1716"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1716/agentshield_0.2.1716_darwin_amd64.tar.gz"
      sha256 "df6e17581252e39e9e206ad927eff6f3d58371d29c64cca573ffe093d9d9954d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1716/agentshield_0.2.1716_darwin_arm64.tar.gz"
      sha256 "21fbd0c4d25611ce7dd699c8792b06529efe30c51e0cff9a23231f7ddbe0dfdb"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1716/agentshield_0.2.1716_linux_amd64.tar.gz"
      sha256 "a2a657858fed7b00e074fedbb12fffca6b13da111bff02907b89af99eed99cd0"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1716/agentshield_0.2.1716_linux_arm64.tar.gz"
      sha256 "501cc1252a72d9aab5518a46e029da827bf0a38f2caf947e29774d4c2e7ac6bb"
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
