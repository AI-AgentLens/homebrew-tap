cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1151"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1151/agentshield_0.2.1151_darwin_amd64.tar.gz"
      sha256 "568d2910e47645dc0c7db4ec9785f539be5221cff754e6dc22162db428d0e4a6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1151/agentshield_0.2.1151_darwin_arm64.tar.gz"
      sha256 "bbcbee5e2dce704fd569487b31686112a49d742ecc2d8112ea48a2a2f363142a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1151/agentshield_0.2.1151_linux_amd64.tar.gz"
      sha256 "868c2ff02561e99a5cc46036a7c2c49282bf030f2055caa8da9e8c77fb1a7646"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1151/agentshield_0.2.1151_linux_arm64.tar.gz"
      sha256 "89de0c43405eddae044cdb4e8d89b2b8d3ccf1716fbc53529d407de6f4f85264"
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
