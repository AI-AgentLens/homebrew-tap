cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.909"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.909/agentshield_0.2.909_darwin_amd64.tar.gz"
      sha256 "aca6853bd8414301c8b0a5e1dc496463e2a280b3edc60952736ad44bd4339c3d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.909/agentshield_0.2.909_darwin_arm64.tar.gz"
      sha256 "3466a5f2fbee2fc896aa82c27d14274f5ada8b5d710146c7e69c7605dfd1a02d"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.909/agentshield_0.2.909_linux_amd64.tar.gz"
      sha256 "4e2296a1d33984cbbc00fa3018d0dae6bb3ed5535ed7f208a3d8392a2dd18741"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.909/agentshield_0.2.909_linux_arm64.tar.gz"
      sha256 "551256542c2378aded2b502288b5910a5cd944975a6c6d388cb914b3f65c0b74"
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
