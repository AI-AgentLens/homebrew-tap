cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2522"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2522/agentshield_0.2.2522_darwin_amd64.tar.gz"
      sha256 "023d81a7d0d0ef0e01a439f02f3c5d1aa0b91cca331a6f84004cf30902978cf3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2522/agentshield_0.2.2522_darwin_arm64.tar.gz"
      sha256 "6e3ce677b23fab6ab99d3cb0ec545e0a42d5ce6c4e19eadf72f8b37207b2c7f6"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2522/agentshield_0.2.2522_linux_amd64.tar.gz"
      sha256 "6bd3b4ff1d34f7d350ddf0def4b7f73b140302b2ba369149400fbe9cb4bd432b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2522/agentshield_0.2.2522_linux_arm64.tar.gz"
      sha256 "6c38d1ff90a398078718f26d7db80992131cd039b764ceb1d00f4ca4c540e55b"
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
