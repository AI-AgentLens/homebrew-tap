cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2321"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2321/agentshield_0.2.2321_darwin_amd64.tar.gz"
      sha256 "7377c6ddfef253fa1949f91f87569718acae73541def5efa1198b50372b52454"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2321/agentshield_0.2.2321_darwin_arm64.tar.gz"
      sha256 "8dfe5b768b65f447fa030b2cbbca44c2dff20863036100b3d0cf7a0c5cfa7dbe"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2321/agentshield_0.2.2321_linux_amd64.tar.gz"
      sha256 "cfcbf4a5f71ab7d0afea37c9116167b35a8b3f436798e1e787629d3cf200992a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2321/agentshield_0.2.2321_linux_arm64.tar.gz"
      sha256 "b5fb4c0f9c2fc507c7332c249ca363ac32a1aa820eaef52c49e8f0a734dab2b8"
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
