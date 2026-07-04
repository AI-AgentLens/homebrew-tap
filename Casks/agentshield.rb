cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1546"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1546/agentshield_0.2.1546_darwin_amd64.tar.gz"
      sha256 "ece0317967028d1c255c59c7dfcc79c245a81bec3167fb565acda12c266ba7c2"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1546/agentshield_0.2.1546_darwin_arm64.tar.gz"
      sha256 "69e83268dc8390cf60d359cf35ed001a47e6b8cb1aa362b1d0f45e860443968f"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1546/agentshield_0.2.1546_linux_amd64.tar.gz"
      sha256 "02ef6769899e8021cdfcb71f91a5f912eeb1edb02825a89c526fcdcaeb560a49"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1546/agentshield_0.2.1546_linux_arm64.tar.gz"
      sha256 "3e4c3fdb9e0d0b4207c1233526c1ed87dba037450518812c204895ed0e54912f"
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
