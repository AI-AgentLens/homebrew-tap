cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.792"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.792/agentshield_0.2.792_darwin_amd64.tar.gz"
      sha256 "b655eee173ba566974254198e4734351f0dd083f808b81046266297b5de96da8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.792/agentshield_0.2.792_darwin_arm64.tar.gz"
      sha256 "45dca1a5eb11e2a1e1a0fc6a1f15da957a864a4f54ea483242001bc252a0c03c"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.792/agentshield_0.2.792_linux_amd64.tar.gz"
      sha256 "06b12850436690bc32b599520cf862d3fc66db6855873d0d660f12f2c91994bb"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.792/agentshield_0.2.792_linux_arm64.tar.gz"
      sha256 "e2e7299ac6ef78226773ede634640328d0e26055f951f52d6aebb8f04a247492"
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
