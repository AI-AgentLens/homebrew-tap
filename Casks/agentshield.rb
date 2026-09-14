cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2137"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2137/agentshield_0.2.2137_darwin_amd64.tar.gz"
      sha256 "4c60afd6c3208036efc2a47ccb010ccdcf65d4c4f7916c4521723d561acd03d8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2137/agentshield_0.2.2137_darwin_arm64.tar.gz"
      sha256 "432dda9c1da1e0635b5c6e277ca6bee8fde58ed78fec94d1401460eeae2f4cbd"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2137/agentshield_0.2.2137_linux_amd64.tar.gz"
      sha256 "1d1375d2a45ba4ab2d6844c01c538da1efdd0016a3b0a1a388937cc7b762b300"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2137/agentshield_0.2.2137_linux_arm64.tar.gz"
      sha256 "d424f7240aa0baf01c92b05cfb3e3c16d6f5398697c3ddba82b0557ca6ab774e"
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
