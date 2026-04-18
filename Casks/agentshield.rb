cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.639"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.639/agentshield_0.2.639_darwin_amd64.tar.gz"
      sha256 "3312b6a4c346e47dcc4058dd24ee5695d436352e07b4ada87221d4ae6bf00455"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.639/agentshield_0.2.639_darwin_arm64.tar.gz"
      sha256 "fe0f38baa3282b4ab1ceaff8d7b52f127a1f526cd5b0c618863e35131f2dff03"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.639/agentshield_0.2.639_linux_amd64.tar.gz"
      sha256 "0aba03ed6444e4e243d6707d44d3d24b61ca74ddbdccceae2dcf5484068e702d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.639/agentshield_0.2.639_linux_arm64.tar.gz"
      sha256 "b255a17e8e0bcc2bf62cbc0c8c48132e9e02cbbb5b07c53db0ac5dab1b40eb6f"
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
