cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.286"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.286/agentshield_0.2.286_darwin_amd64.tar.gz"
      sha256 "b4c4f808a1f5fe6415452e2df3ce7ddb3bfe475c205f587169f17777fc59f352"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.286/agentshield_0.2.286_darwin_arm64.tar.gz"
      sha256 "552c4e381a545608fe3ab1cfadc95582f557d781a847e8bea2a8f80909f27c22"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.286/agentshield_0.2.286_linux_amd64.tar.gz"
      sha256 "f5b5bf316af8c5153482cac4a1a0ef77ca51737da855eeb8248e0f42e8ad9354"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.286/agentshield_0.2.286_linux_arm64.tar.gz"
      sha256 "a39ed9739a13b0fbc695c591ba208c79cfa81deb02a7860e1277eec9aa3f749e"
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
