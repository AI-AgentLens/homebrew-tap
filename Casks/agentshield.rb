cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1990"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1990/agentshield_0.2.1990_darwin_amd64.tar.gz"
      sha256 "2513b36c78f9a37f0625daa5ac40031e702611f2bbef06c72c4b351eaee94b3f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1990/agentshield_0.2.1990_darwin_arm64.tar.gz"
      sha256 "e4d9719a9f0512f4c71c2e6932fddeb24fab11f878a829234e57065f6a8d580d"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1990/agentshield_0.2.1990_linux_amd64.tar.gz"
      sha256 "635179cf6762e1785030668234c23997eb3f10ee5f314e84aeaca1ed57c67e8c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1990/agentshield_0.2.1990_linux_arm64.tar.gz"
      sha256 "e17e8d754b913e8bd03848e9ceead54604d4c7e21cb5a307af0368af5df7458d"
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
