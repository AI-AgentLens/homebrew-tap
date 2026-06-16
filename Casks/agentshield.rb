cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1337"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1337/agentshield_0.2.1337_darwin_amd64.tar.gz"
      sha256 "2ee5133bcc82773a0b331ecc54aa44bfcac56e0b3dd15a5f98a5e6a03b200582"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1337/agentshield_0.2.1337_darwin_arm64.tar.gz"
      sha256 "9d623898e08184b7e22a305febe940b84092e416f4430ee4fd206c111eae2602"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1337/agentshield_0.2.1337_linux_amd64.tar.gz"
      sha256 "08a3a9aa3196b4e0e6feb0608eab55cf01efbf184cdcdf9f10948f6e1ad2d817"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1337/agentshield_0.2.1337_linux_arm64.tar.gz"
      sha256 "9be52780ff59ec31339468b9f85c1e61efbc9a244e84d6e6a004f285b27867d4"
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
