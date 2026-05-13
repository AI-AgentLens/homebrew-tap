cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.968"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.968/agentshield_0.2.968_darwin_amd64.tar.gz"
      sha256 "a68352ebe40f174fdb40edcf937af574c6a758e20950c3e8da908ac3f9e58df8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.968/agentshield_0.2.968_darwin_arm64.tar.gz"
      sha256 "57248551940459be084a18b7a6b20dd7830539e64c4f2354de286678687b534f"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.968/agentshield_0.2.968_linux_amd64.tar.gz"
      sha256 "bb6c16364ea8f31bd387d448cad60d1b85b2b52a7bf61a0d803d0957d5beb05f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.968/agentshield_0.2.968_linux_arm64.tar.gz"
      sha256 "f98cd825dae870ba77cb49c320582d39b926e071aa6eb4a0504dc4ae09b7d507"
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
