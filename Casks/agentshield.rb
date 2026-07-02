cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1526"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1526/agentshield_0.2.1526_darwin_amd64.tar.gz"
      sha256 "8a9494457688a3d1cd7a2b357997e1164a9934bb352a862d3a95e32bd21369bf"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1526/agentshield_0.2.1526_darwin_arm64.tar.gz"
      sha256 "1104b909556c2d801e7527731f60a3a6f498c9fa78fdbfcc1b762beea61167e0"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1526/agentshield_0.2.1526_linux_amd64.tar.gz"
      sha256 "0b5e64c758e50b6d607c8a4f31aba6de58581b937aff50566d08e78035982e1e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1526/agentshield_0.2.1526_linux_arm64.tar.gz"
      sha256 "323b73341341ed48a0047172394bc58669a39cc033a3356addf270e843a2bf1d"
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
