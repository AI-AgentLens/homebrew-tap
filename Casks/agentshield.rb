cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.283"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.283/agentshield_0.2.283_darwin_amd64.tar.gz"
      sha256 "71aa5c309208bc76162e229b810e2559e8de3efe623001cdfc91b51e3b619d10"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.283/agentshield_0.2.283_darwin_arm64.tar.gz"
      sha256 "bd5aac6bc782c5c2665b5b9dfb1a429042a8f52fe7d8edc135254afc3a1a228d"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.283/agentshield_0.2.283_linux_amd64.tar.gz"
      sha256 "c033fdfa3042b98001a8d74fe082b3f0c20f9d17b4de8601f62d67c5e6c2f531"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.283/agentshield_0.2.283_linux_arm64.tar.gz"
      sha256 "0303a9d9872933e066e5f0b83337931275f42796bb80f0ce48192e118a3fe70b"
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
