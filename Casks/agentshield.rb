cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.195"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.195/agentshield_0.2.195_darwin_amd64.tar.gz"
      sha256 "c3d4dcdc66eac4cbb0b3ccdce3bf6fd4582a49ee92dec1345482684def8c0aba"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.195/agentshield_0.2.195_darwin_arm64.tar.gz"
      sha256 "f22e54640325f5dea4fe34b854e0618d2d5d0786d09c9f1e738abcd40afb8504"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.195/agentshield_0.2.195_linux_amd64.tar.gz"
      sha256 "d50955469f38a7a854243ff2f2f5ea22b7e5b8b58d1ea2f94953a4b345f1cdae"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.195/agentshield_0.2.195_linux_arm64.tar.gz"
      sha256 "fb5c63f62e9cb04251d095d6a84c6045a140e99d061d3b9e60a1c5eb6643e88f"
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
