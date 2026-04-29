cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.803"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.803/agentshield_0.2.803_darwin_amd64.tar.gz"
      sha256 "2a2875f807fb77440e9098c47c67c74a65e164c4d1a2856a651e2a0830908db5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.803/agentshield_0.2.803_darwin_arm64.tar.gz"
      sha256 "6d36736abb8569ce636cb66d7b8185e0281d9e0a2b5140ef7d3ccef2497f450f"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.803/agentshield_0.2.803_linux_amd64.tar.gz"
      sha256 "329ddcf1abe17acfad9c69de4d1290304282cb71db6b4b3bcfa00a0d4363fd43"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.803/agentshield_0.2.803_linux_arm64.tar.gz"
      sha256 "c8d2a8d051defb801953c35fc87d954708a3e6212f6d6dffafad09f29a599066"
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
