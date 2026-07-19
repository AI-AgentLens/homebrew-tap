cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1679"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1679/agentshield_0.2.1679_darwin_amd64.tar.gz"
      sha256 "511e0094de1965e6908699df2e9bc5ad44816e04b5d3dff602e2ce6859903c0c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1679/agentshield_0.2.1679_darwin_arm64.tar.gz"
      sha256 "79311e10ea83ccae5a472397570d31eff98ee6c5c24f721cfea2420f88b3f013"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1679/agentshield_0.2.1679_linux_amd64.tar.gz"
      sha256 "981e86553af3acbe3099ff493e00964bbab3317d38c64f00db33974d88df2bfd"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1679/agentshield_0.2.1679_linux_arm64.tar.gz"
      sha256 "569fce61c202844c5dc07d71cdeb21fb94673a0c1fc8bf9fd8fe1910d24dbf51"
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
