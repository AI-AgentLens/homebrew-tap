cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.955"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.955/agentshield_0.2.955_darwin_amd64.tar.gz"
      sha256 "368ad5e0a2d06647ed5e2893963f31bc3a890bce7c13b3630bcf17b1c9cf0805"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.955/agentshield_0.2.955_darwin_arm64.tar.gz"
      sha256 "567fa2f9b8e74103cc3862a81f1d285b48f875db71b1e562f90c1d8094647e18"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.955/agentshield_0.2.955_linux_amd64.tar.gz"
      sha256 "1f4ffe4ab410bccdad24aa9f807db8d039d7ed73a2bf35a4f90fa555cdc3315e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.955/agentshield_0.2.955_linux_arm64.tar.gz"
      sha256 "0cb05078c31b173fca57972e36c157e6940f60d552cc13b12dad3a99f90a7bd3"
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
