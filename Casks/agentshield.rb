cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1537"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1537/agentshield_0.2.1537_darwin_amd64.tar.gz"
      sha256 "79f60345c0e0e487c1501c2164b7829ac401ec89bd4b1cd575ead881c83ac182"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1537/agentshield_0.2.1537_darwin_arm64.tar.gz"
      sha256 "977391d938e2b84f4aabb39a3a51e611ae5dfdfa76857d60938ae4be9c14c6a5"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1537/agentshield_0.2.1537_linux_amd64.tar.gz"
      sha256 "3ba55f241461df87f47b9b876440112e272ee1bd6767b4c97bda015cd396afc6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1537/agentshield_0.2.1537_linux_arm64.tar.gz"
      sha256 "a147346bb8bd2bd6064028992b25dd759fe75a04f6e8a55a8b00110baa280e36"
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
