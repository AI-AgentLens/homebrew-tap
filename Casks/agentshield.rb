cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1471"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1471/agentshield_0.2.1471_darwin_amd64.tar.gz"
      sha256 "b472647564695c37a1ecfee648b02709889f91ab15b092ac4902c919987e0e95"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1471/agentshield_0.2.1471_darwin_arm64.tar.gz"
      sha256 "7dc8cd7e0de5a5ad36c1e1be3fee2c4ba1ddbd73d666ecca6ac50ddbc9d92266"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1471/agentshield_0.2.1471_linux_amd64.tar.gz"
      sha256 "afe9de22c244fa05115a7dc290fe0218c6f320544ede92728cf642878b03a848"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1471/agentshield_0.2.1471_linux_arm64.tar.gz"
      sha256 "50974c0a99e6d467a214dbbc6671545f78a04f127fb19407e9e76ca63242cd5c"
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
