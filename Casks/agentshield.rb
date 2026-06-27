cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1457"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1457/agentshield_0.2.1457_darwin_amd64.tar.gz"
      sha256 "db51a87093a44681af75d539e1f4d0a94a7a1dde41883bce07d462b1eefee05e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1457/agentshield_0.2.1457_darwin_arm64.tar.gz"
      sha256 "a4e2c87196af84dac1406cafe3f7aad6f01095ef768ed182f64bdeddd537188f"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1457/agentshield_0.2.1457_linux_amd64.tar.gz"
      sha256 "d8421d9923c6bd0073322e86d162ac30ea8adb0cfa7986b06b25f9ecc6d55056"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1457/agentshield_0.2.1457_linux_arm64.tar.gz"
      sha256 "0e23a4dd610c90e2c417dcb27d7f678a7f94fd1c1ae420c9503c41ad1dedde40"
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
