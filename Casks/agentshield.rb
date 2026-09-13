cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2133"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2133/agentshield_0.2.2133_darwin_amd64.tar.gz"
      sha256 "66be37170d3b8e32874b7a518cb858148e7a2784cd428676cfce53f4280e7fff"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2133/agentshield_0.2.2133_darwin_arm64.tar.gz"
      sha256 "398bd729ce7b4fb016cfd8cf30b149ae765e89f2f649b0c8834b64b2ab48fd45"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2133/agentshield_0.2.2133_linux_amd64.tar.gz"
      sha256 "27b9d52484ea2fa64a8215dd8a9feeefd5c6b4ec9908edc2a18e46cd0ba8706f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2133/agentshield_0.2.2133_linux_arm64.tar.gz"
      sha256 "2174f2b9cf564e13f2d44b563c2395e252cf297ab1243a032b2992fab50f163c"
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
