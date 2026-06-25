cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1448"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1448/agentshield_0.2.1448_darwin_amd64.tar.gz"
      sha256 "6e64a98462042336a4ec79e59aeba82acc8166d9fd182e4aea7b5c88cf230e20"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1448/agentshield_0.2.1448_darwin_arm64.tar.gz"
      sha256 "97ddaf20572c41c5171b469b031002be95ca4224825cbdd60a61a944f0846208"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1448/agentshield_0.2.1448_linux_amd64.tar.gz"
      sha256 "976793674d0afd5a763c7d494394bb5d3ef2cd7082a67f3dcb06b9673f66a9f4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1448/agentshield_0.2.1448_linux_arm64.tar.gz"
      sha256 "7509e651a678a65c317996c8d02dc360ed56ded28c29e678627d9bd036d53ee3"
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
