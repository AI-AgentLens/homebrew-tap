cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1512"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1512/agentshield_0.2.1512_darwin_amd64.tar.gz"
      sha256 "6306c97ab769942caee8fb37f28d5190da4ea4562d902e1cbbafdf19369b2414"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1512/agentshield_0.2.1512_darwin_arm64.tar.gz"
      sha256 "883deb2dad4c0ba9adff15a4d8546b371da1eefd2f83e86af724834f48da2a20"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1512/agentshield_0.2.1512_linux_amd64.tar.gz"
      sha256 "bdd13d367ef0d7e53e5d9633ed407933f617f05fbaadeaeaba7607dccf359de4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1512/agentshield_0.2.1512_linux_arm64.tar.gz"
      sha256 "c3312019d8bf64538b6733ba53032ab96c8ee3c99c9151dc3467fedac780e99c"
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
