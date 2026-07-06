cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1565"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1565/agentshield_0.2.1565_darwin_amd64.tar.gz"
      sha256 "94cd905bf032853c1547a6dfbcf28b48763c40cfe8bb97fe60b29fd3fed0f987"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1565/agentshield_0.2.1565_darwin_arm64.tar.gz"
      sha256 "48c131e4a622aa7b192b550869094f718be737bbd485f4770184a9d65d7cc1ab"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1565/agentshield_0.2.1565_linux_amd64.tar.gz"
      sha256 "3b1032918cda8a600cf736934e03935a315e295b32d99850ef4090c2141c0e5e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1565/agentshield_0.2.1565_linux_arm64.tar.gz"
      sha256 "4e2253b44577293ae4c2cf5e26f703747118adbe7fbacdffebcede22282b0e8e"
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
