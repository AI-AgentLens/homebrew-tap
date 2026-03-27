cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.96"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.96/agentshield_0.2.96_darwin_amd64.tar.gz"
      sha256 "c5b47db27c4ef98d4172dd0ae67a334fc60b2a705c13c7c45683d39bd71ac1c2"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.96/agentshield_0.2.96_darwin_arm64.tar.gz"
      sha256 "082e9f7b381961ab9b271d2b2ed044c7e6556363e2981db636439f259c447250"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.96/agentshield_0.2.96_linux_amd64.tar.gz"
      sha256 "4bc73dc4ef31167d6fd159ce1cf5a86309516c24efd3ea7dfd9ccd80c061f838"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.96/agentshield_0.2.96_linux_arm64.tar.gz"
      sha256 "a000a0c96eb5309dfce4c4270dabbf6afcc76578d40e4c40af52d2c856e72dd3"
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
