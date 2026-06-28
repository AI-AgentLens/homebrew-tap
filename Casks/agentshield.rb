cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1481"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1481/agentshield_0.2.1481_darwin_amd64.tar.gz"
      sha256 "16190cbe4fce0942420bdc4333e094003ef08452f243eb4a409bd189a1eda883"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1481/agentshield_0.2.1481_darwin_arm64.tar.gz"
      sha256 "197f3c470f5eb851773e857f82029773342795d33b6e5ff1a44b47211c623090"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1481/agentshield_0.2.1481_linux_amd64.tar.gz"
      sha256 "5b3ddccb4a6de39e9c5a3352586a71f2ed0579d1d797d7c5d401d9a9b26d2002"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1481/agentshield_0.2.1481_linux_arm64.tar.gz"
      sha256 "490741d0eed613d7531bc36a599b2df8a48200f56e2b48cc9f4837d883dbb657"
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
