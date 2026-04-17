cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.620"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.620/agentshield_0.2.620_darwin_amd64.tar.gz"
      sha256 "321f2983cd3970e85b3b7d0bc52459a2c42457bf6f4940e84c251d1cc1cd2992"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.620/agentshield_0.2.620_darwin_arm64.tar.gz"
      sha256 "cb54bec632eb1ccfc985b13f746994d82f3b1f0dfc41efa30cb8237de4556603"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.620/agentshield_0.2.620_linux_amd64.tar.gz"
      sha256 "d8041f00710edf35cd43a74a0dd3ae6130d23e105d7d97b5241fb5c637974aae"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.620/agentshield_0.2.620_linux_arm64.tar.gz"
      sha256 "b6ae3b9398da48839fee13eadf40dfaf3aa499cb243f507206621d68a4147341"
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
