cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2303"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2303/agentshield_0.2.2303_darwin_amd64.tar.gz"
      sha256 "07647616f7e8eb6fa1d0dacc969aeca947bf6e31d3f57a32dc55ee250f19e3e3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2303/agentshield_0.2.2303_darwin_arm64.tar.gz"
      sha256 "8a0842c6a5ce80d28d3b6363e98aa0255f72c1ad11de4ea65cc9cf6a7c35ce6c"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2303/agentshield_0.2.2303_linux_amd64.tar.gz"
      sha256 "26ce996e5c94b945564fcf22451635d723e3d6b8330a2a5877d6463b54ac65e3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2303/agentshield_0.2.2303_linux_arm64.tar.gz"
      sha256 "4a91670992c2189e373e67bc49532f866d6d752ceff27cb4317273eb648887c5"
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
