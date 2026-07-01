cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1508"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1508/agentshield_0.2.1508_darwin_amd64.tar.gz"
      sha256 "f3ccc7d8a97dca9374c88e83a7c59819adeffdcb5ff212a184688b1fa0940af7"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1508/agentshield_0.2.1508_darwin_arm64.tar.gz"
      sha256 "0d92330bfdb8fddf4f707a3a17499e9c10ed7146c50ae3661b7bec2c5b661855"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1508/agentshield_0.2.1508_linux_amd64.tar.gz"
      sha256 "ca1b39e525c6b8edfeae24e8ab05ab2034d1fe93b0ea9a8ac84c313c0dc0b4a6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1508/agentshield_0.2.1508_linux_arm64.tar.gz"
      sha256 "a2a754c574b5a432676784cba7eddadcd3d22a1f2865d4a5302f3562b0136c56"
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
