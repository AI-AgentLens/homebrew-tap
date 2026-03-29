cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.201"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.201/agentshield_0.2.201_darwin_amd64.tar.gz"
      sha256 "19ba917997ae4f75c75d410ca7c0bb45280ce83b1fa05dff8e8026e217465929"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.201/agentshield_0.2.201_darwin_arm64.tar.gz"
      sha256 "399be9123ba8989e2c2a773c8bc0d3621ab7d2090f06ddcbb495575cee9f4c39"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.201/agentshield_0.2.201_linux_amd64.tar.gz"
      sha256 "7ee98357347371f0cb6b0d5b9560a1421c76586bed8f725690caf3947acbc106"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.201/agentshield_0.2.201_linux_arm64.tar.gz"
      sha256 "a2c1c0c4275556e37a1da86f0aa296bfdfee8f3dcbe0b5e551a9880ee2fa0afe"
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
