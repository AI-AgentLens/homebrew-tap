cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2218"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2218/agentshield_0.2.2218_darwin_amd64.tar.gz"
      sha256 "020a345bc1931df30ae5a1a8ea3621d89e3c36390af3173e86195d6490ac202c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2218/agentshield_0.2.2218_darwin_arm64.tar.gz"
      sha256 "d356d68277dcce7d77ac8cf3600a64d23ab11b978114b83a790522febc741d56"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2218/agentshield_0.2.2218_linux_amd64.tar.gz"
      sha256 "574ed8f98e2474c9f378f5e031f04b46fd4b1eaaa732dd8903cbbbe3e0dbb04c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2218/agentshield_0.2.2218_linux_arm64.tar.gz"
      sha256 "d7833529acec15c7e052ca88f6b34deaab1e92799cb63a010435813301bd51a8"
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
