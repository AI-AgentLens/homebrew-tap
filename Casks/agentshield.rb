cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1171"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1171/agentshield_0.2.1171_darwin_amd64.tar.gz"
      sha256 "543d8520f852f26ff29753ecf33e05f7c625a34a9e540fe05866b06549a3703b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1171/agentshield_0.2.1171_darwin_arm64.tar.gz"
      sha256 "3aa5eb0737e127f87361401544a95adfc00c673d2e909ffe06d564dac1c2dd85"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1171/agentshield_0.2.1171_linux_amd64.tar.gz"
      sha256 "ff732077c968df64df9d9ed0aca4e3c6071df44916b4c1d35d9c2e1013836f4e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1171/agentshield_0.2.1171_linux_arm64.tar.gz"
      sha256 "d8c2fc2d7b0c5200073c9c1015a9a1ae562a373e2c48a84f7d32785ecdd629ed"
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
