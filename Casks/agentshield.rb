cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.943"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.943/agentshield_0.2.943_darwin_amd64.tar.gz"
      sha256 "3b542352a50811cd39b35b41f264b3fb1aad683fb566e8682feaf26fce45fab6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.943/agentshield_0.2.943_darwin_arm64.tar.gz"
      sha256 "e73598cf13e2342d5af3d47700e31bf305b47f98fb20bc7528e54bb3b7c40c96"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.943/agentshield_0.2.943_linux_amd64.tar.gz"
      sha256 "034d1576e4ee2d44ed721f6571984714ee60715bef8037834def02ea043e2d95"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.943/agentshield_0.2.943_linux_arm64.tar.gz"
      sha256 "06b4dd874a1490b480c77e4c9f0d9b530de9e46fbc85f87ff7f7ceeede540696"
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
