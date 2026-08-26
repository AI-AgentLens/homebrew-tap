cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1957"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1957/agentshield_0.2.1957_darwin_amd64.tar.gz"
      sha256 "48dea1696ee71a9e37789307ed3dc3b0f297f4b65f0db1e07b501040ccf0ee43"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1957/agentshield_0.2.1957_darwin_arm64.tar.gz"
      sha256 "03f5dcb5aa98bdfc1119a74a35e4dfe80b719435f2b826a772eb55637b71ec5f"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1957/agentshield_0.2.1957_linux_amd64.tar.gz"
      sha256 "b97104b0a05ee5d37269b428fc432561738045139a02c885407a4fcefb947894"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1957/agentshield_0.2.1957_linux_arm64.tar.gz"
      sha256 "d06c48c593545c0f172cd633710691cc93c11650f26d3d8835b8138ba0e3072f"
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
