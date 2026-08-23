cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1931"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1931/agentshield_0.2.1931_darwin_amd64.tar.gz"
      sha256 "7ffa5a34b53da7eed9d26d0971244a12b853257c2d1f5e2d31f018739eb9f07a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1931/agentshield_0.2.1931_darwin_arm64.tar.gz"
      sha256 "f22fe6381e4bf4b1577b6cdfc108d04dae10642268b3e5d6e126fdb31961e256"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1931/agentshield_0.2.1931_linux_amd64.tar.gz"
      sha256 "fed61e8758ec4fa11b597ca6659fb28a7a55f3d53ad5f7b9c6f93642d3355e82"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1931/agentshield_0.2.1931_linux_arm64.tar.gz"
      sha256 "ddad8b1b686c1c4c3314e96e7104bb5961810122e1e28cbd224703082b97460c"
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
