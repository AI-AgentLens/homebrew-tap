cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2093"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2093/agentshield_0.2.2093_darwin_amd64.tar.gz"
      sha256 "62b8f4f7adecfa0c34af5b9fab15cd0c7687c3a158dfa069a388d91687da9dbc"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2093/agentshield_0.2.2093_darwin_arm64.tar.gz"
      sha256 "82be48bd45f2e2659ac38257ee5d61456e347e966fc8cc1e392e4a8ea534c708"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2093/agentshield_0.2.2093_linux_amd64.tar.gz"
      sha256 "8b6aa49a87d4710b45ef14fe3fefb3da56be128eb0709e785625dfd4a37e01cb"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2093/agentshield_0.2.2093_linux_arm64.tar.gz"
      sha256 "89382056e880bab21160907fae3bee6de58f8cd538b1a623504b849e4e57d8ea"
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
