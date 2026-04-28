cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.784"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.784/agentshield_0.2.784_darwin_amd64.tar.gz"
      sha256 "de7fddce02fc9e51a227e60cdb0394c4fde318ebcc74015305da069a6e6fda24"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.784/agentshield_0.2.784_darwin_arm64.tar.gz"
      sha256 "5a5819227a3d3863bac2473a460688f2375fdf932df1de94268ba9e342e59876"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.784/agentshield_0.2.784_linux_amd64.tar.gz"
      sha256 "2698768808fbb32ef9e58e209fc3e3a60828ddead95e723601130cb7dc2f9e84"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.784/agentshield_0.2.784_linux_arm64.tar.gz"
      sha256 "b12dd2f92a2c16e2d3b82844a7ae4a7ebb285e10dce8149d60b78fd40acf2aee"
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
