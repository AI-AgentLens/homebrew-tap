cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1607"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1607/agentshield_0.2.1607_darwin_amd64.tar.gz"
      sha256 "e2bddf35a4654c7bdda6588092c326f5f2032115d711c599f3f534886d8cf59c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1607/agentshield_0.2.1607_darwin_arm64.tar.gz"
      sha256 "6fa3daa8ccdb21898facc4f80a0cadfbdce14ac4bcd3fa78f73ff60d7542d220"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1607/agentshield_0.2.1607_linux_amd64.tar.gz"
      sha256 "e681ec335d0946af6b05be673091ed8312c78294bfc6efbd4c7b5d6a1d048e35"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1607/agentshield_0.2.1607_linux_arm64.tar.gz"
      sha256 "31fe7cfc36e05b92a283385132c82f87d95d9890e142a0884003f7e36600c78f"
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
