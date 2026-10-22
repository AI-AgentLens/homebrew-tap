cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2502"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2502/agentshield_0.2.2502_darwin_amd64.tar.gz"
      sha256 "56e4540b240b1b958aacf134ed7818d18f7cce67d19c777af461dbc3ee6ea90b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2502/agentshield_0.2.2502_darwin_arm64.tar.gz"
      sha256 "dd8f27b1ef5467043bf03383dc1b106b5fc73b1406b9c1228a72f22a07777c47"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2502/agentshield_0.2.2502_linux_amd64.tar.gz"
      sha256 "e17371fc5f4ba6894a068224fe5f115475e757b8db7b9b3fd884facf7667a563"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2502/agentshield_0.2.2502_linux_arm64.tar.gz"
      sha256 "b30b14bde093694b41fed169da9ca875e902bb7af4ad53133cea753fe1949186"
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
