cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1907"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1907/agentshield_0.2.1907_darwin_amd64.tar.gz"
      sha256 "27c8ed02dbe8fdce2dde8f97f1994b6d98bfadc18cad23c1c85566d02cfc92ec"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1907/agentshield_0.2.1907_darwin_arm64.tar.gz"
      sha256 "3fcdfd03692b081b0866724199aa6226c596cfa735ac997784f8f97232759607"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1907/agentshield_0.2.1907_linux_amd64.tar.gz"
      sha256 "30141b9cb291caeb2a2c767ee1639f67d094d5f2bf906c2e433741ab9ad8010f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1907/agentshield_0.2.1907_linux_arm64.tar.gz"
      sha256 "ef573892c0c7969aab6d82914d2de0dd11937ab253c034f8eb00cb8564d897ba"
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
