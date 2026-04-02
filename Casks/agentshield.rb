cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.311"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.311/agentshield_0.2.311_darwin_amd64.tar.gz"
      sha256 "a0b7b6bba965f6ac32e4b32ed40de0adb38a55501e36a000cf2cde236405efbf"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.311/agentshield_0.2.311_darwin_arm64.tar.gz"
      sha256 "e169985bef2e79181d4f6ef6a185ebc31b7b83e8cf7c9e56c1b4b8fb1ae7be54"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.311/agentshield_0.2.311_linux_amd64.tar.gz"
      sha256 "e7b6f5e9bbd9c1aaaacae88b0a7f063f57967e1f34cfc6647cff3acd00a5235d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.311/agentshield_0.2.311_linux_arm64.tar.gz"
      sha256 "5a06178c9c1853b6881d8cd72fc22b27537a004bf7519bf39c90a62a75fc2155"
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
