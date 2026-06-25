cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1442"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1442/agentshield_0.2.1442_darwin_amd64.tar.gz"
      sha256 "513cd2229da1d577cb5678be5b8cbf606e1cfc58f5470d24482c7c1c76309212"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1442/agentshield_0.2.1442_darwin_arm64.tar.gz"
      sha256 "239530f8647431562fc12004494484b12f73840aac4afc880417b28f50e9d592"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1442/agentshield_0.2.1442_linux_amd64.tar.gz"
      sha256 "538ef8fa9d9fde8d1c5908fdd8b7b08a8c01fe109cb07a6b604511d8cd87e41b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1442/agentshield_0.2.1442_linux_arm64.tar.gz"
      sha256 "036468b8ad2249365a5a35bcca188dbd0ae4ba102d04e30216044063a1e51c6e"
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
