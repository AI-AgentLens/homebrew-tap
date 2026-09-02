cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2025"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2025/agentshield_0.2.2025_darwin_amd64.tar.gz"
      sha256 "5d668051e34db5e79f3483fd182bfddc27ae393842a451b3591d0279b725fa46"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2025/agentshield_0.2.2025_darwin_arm64.tar.gz"
      sha256 "f1305099ea1df9c842e1c679e8600fbd4a71bee8adac4807594e9fffbefa7405"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2025/agentshield_0.2.2025_linux_amd64.tar.gz"
      sha256 "71a7ef82de3499fb51c7ef355857de04da6f47359b29875cbb8abe208379edb1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2025/agentshield_0.2.2025_linux_arm64.tar.gz"
      sha256 "16fd20dbd256d2efbc321df0dff158ffd4136d6696f6798fc323b4d8012188d7"
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
