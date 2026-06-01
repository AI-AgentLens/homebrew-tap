cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1175"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1175/agentshield_0.2.1175_darwin_amd64.tar.gz"
      sha256 "895dcfbc2c0f777e411bac99e5d370b07b2510ad54b5a0473a7a168b2fa38339"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1175/agentshield_0.2.1175_darwin_arm64.tar.gz"
      sha256 "da3d632acce6f9d2e03175056032db689594c471b8c2014482b9ebdee9b0abab"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1175/agentshield_0.2.1175_linux_amd64.tar.gz"
      sha256 "71bc3223033b7b76d694fcaf224ebdf6c094adcbd74160c7e7c150ea0ade29c0"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1175/agentshield_0.2.1175_linux_arm64.tar.gz"
      sha256 "99ed281df2a77b35e020283acc769a0253541fcff896ad80b9d772313bf4380a"
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
