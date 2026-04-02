cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.340"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.340/agentshield_0.2.340_darwin_amd64.tar.gz"
      sha256 "faf2337fcb29674bf57a49573595952be142054076eb8a449054ae3ba9791c8f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.340/agentshield_0.2.340_darwin_arm64.tar.gz"
      sha256 "af873dab0346c897d7b8578dd5a269478aaf6621849b34a71f54f4695c4f630a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.340/agentshield_0.2.340_linux_amd64.tar.gz"
      sha256 "4c31d211167041864273dbb1391a5a5147e193d0cf6800912761f7c06a260103"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.340/agentshield_0.2.340_linux_arm64.tar.gz"
      sha256 "a73478df1ec56acddbd4b3300e6f21796348467ff28f31ba065dbb599db0d7d0"
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
