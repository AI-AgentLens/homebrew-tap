cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1502"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1502/agentshield_0.2.1502_darwin_amd64.tar.gz"
      sha256 "d8dd44e406611a2d7b4fcec9fdd4577bff1344438021756eea2432291c2e64e0"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1502/agentshield_0.2.1502_darwin_arm64.tar.gz"
      sha256 "e4f27241e9c1d4c4d093f82fa4c5d71cb9f73aab161d09ee9a6f8bef2891e214"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1502/agentshield_0.2.1502_linux_amd64.tar.gz"
      sha256 "a53a69b5267f90a48b05ee8b145f28237fde6ea4b3997ab0f31c88f87cb79013"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1502/agentshield_0.2.1502_linux_arm64.tar.gz"
      sha256 "4d3771110b648d2c64389525828ce7addbaa2844e5044c2c1e407853d0d9a920"
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
