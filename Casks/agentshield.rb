cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1335"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1335/agentshield_0.2.1335_darwin_amd64.tar.gz"
      sha256 "fe5575dfe2ff12e65187c3dec255eccf1e30d0f074a42b2dd7b8ce7cb498a31b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1335/agentshield_0.2.1335_darwin_arm64.tar.gz"
      sha256 "400811ad5df83abb1cb626e4783bcfbee3d59c1102444f14e369e9a07c0f8ef4"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1335/agentshield_0.2.1335_linux_amd64.tar.gz"
      sha256 "71f04e5c218f523b44e52e1d09197b5287f532aa976277b4a0e3ec77eb395c45"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1335/agentshield_0.2.1335_linux_arm64.tar.gz"
      sha256 "3eead218cfc977a134ce7e8b84e160297bbdd337c7d8afb0e9e802d4c89a8a68"
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
