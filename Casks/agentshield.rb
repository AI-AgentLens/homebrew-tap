cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.911"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.911/agentshield_0.2.911_darwin_amd64.tar.gz"
      sha256 "4faecf5c7eaa19a87f1d042f7129a601b11686ab7b05834cfb1bd933b34a90d7"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.911/agentshield_0.2.911_darwin_arm64.tar.gz"
      sha256 "4aa6ea48ab533fa5f5a053b90f061591634e2a5669d8dfde2a4c663cdbf77af2"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.911/agentshield_0.2.911_linux_amd64.tar.gz"
      sha256 "8cfdc4d9ae1d4b25b2f16367b3d370da23a85c21bb28388f1849e3ae519bc755"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.911/agentshield_0.2.911_linux_arm64.tar.gz"
      sha256 "c1ee947b08097ce5dbc69fce305bc4608e5378e1d090759fa8bcf1462dc9aab1"
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
