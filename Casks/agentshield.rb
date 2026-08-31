cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2006"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2006/agentshield_0.2.2006_darwin_amd64.tar.gz"
      sha256 "df947acf0f713c0138902bd985f94a1e07ada1bc46c52ddb6cbdab9cfce5a6a5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2006/agentshield_0.2.2006_darwin_arm64.tar.gz"
      sha256 "68647a6c59a6aeb66cc4d0f292abf3637006c6e652614ce81484c933d2607c2e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2006/agentshield_0.2.2006_linux_amd64.tar.gz"
      sha256 "3e370f2b8f89f3755c5706c9f4117f58771a27e75a13b2009e8662067be85208"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2006/agentshield_0.2.2006_linux_arm64.tar.gz"
      sha256 "1cb9ed86b46d959e0db10da98467feddeca96af47fc66f69f7062d6fbd23a706"
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
