cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1096"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1096/agentshield_0.2.1096_darwin_amd64.tar.gz"
      sha256 "9217a185b960d41e801d622ad44c6255494e44aa0783e64b30c7ab96b9ae5627"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1096/agentshield_0.2.1096_darwin_arm64.tar.gz"
      sha256 "de908188cc5aff5b683f47fe9091fee9068e80e5f90b9cd585a2cd78b5b7410e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1096/agentshield_0.2.1096_linux_amd64.tar.gz"
      sha256 "b562ebc3249038e265c2b9f91ede5a28288c1975c2a13140e71a960dc7d90bd3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1096/agentshield_0.2.1096_linux_arm64.tar.gz"
      sha256 "ddf06571df0f9ba87cb6786f3ad04b42555107ee0da3ee70cf456958eba8d4bf"
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
