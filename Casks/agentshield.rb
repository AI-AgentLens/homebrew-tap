cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1902"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1902/agentshield_0.2.1902_darwin_amd64.tar.gz"
      sha256 "11394ec94266cc8be570bac0056be2cb3022b4b91e78ef17ed427704a1341a61"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1902/agentshield_0.2.1902_darwin_arm64.tar.gz"
      sha256 "848bb7191364852d77f2df19d1ebd3777b552cb6c12d57d3cf386920d86cd3cf"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1902/agentshield_0.2.1902_linux_amd64.tar.gz"
      sha256 "5681d0f0a9c3ad69f5198ebce18aa0d761568279761af0df6ffab90e5fbed454"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1902/agentshield_0.2.1902_linux_arm64.tar.gz"
      sha256 "0fafe6df69ef066484206f2eecf4f04a79df7d1feb1aaa69a6a2e88e20b73148"
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
