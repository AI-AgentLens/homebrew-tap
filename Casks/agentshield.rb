cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1385"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1385/agentshield_0.2.1385_darwin_amd64.tar.gz"
      sha256 "4d828b675a1c4574cfc9226c05f34b448c7b8ce58c37ed2946a7217261de09c7"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1385/agentshield_0.2.1385_darwin_arm64.tar.gz"
      sha256 "55271e417dbe2df7d7091662fa7e4db008d92ea6f94a93d2e48c37a236d915d3"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1385/agentshield_0.2.1385_linux_amd64.tar.gz"
      sha256 "8e0443d5f67563093ae8065d4559e1308e47d9829ae53801f043186a55ae7b85"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1385/agentshield_0.2.1385_linux_arm64.tar.gz"
      sha256 "faf60622c4f1da7b17fd5b2b9d91e6ed3718637a0508b66c0c120532448d698c"
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
