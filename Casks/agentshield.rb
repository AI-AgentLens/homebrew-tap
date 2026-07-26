cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1734"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1734/agentshield_0.2.1734_darwin_amd64.tar.gz"
      sha256 "c1042b965c5f5dd033b46b706f166252f87effbb66d124fcf26d6baf3830341c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1734/agentshield_0.2.1734_darwin_arm64.tar.gz"
      sha256 "1f946d29bfbd2ec1335b32c9b7b39c522eacf185a1af5d212106fe944c4b341c"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1734/agentshield_0.2.1734_linux_amd64.tar.gz"
      sha256 "23b50db99ee202f90bed189cf34dfdb2efc0e11d9efe3a00a01d6cd56f26cab4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1734/agentshield_0.2.1734_linux_arm64.tar.gz"
      sha256 "8d98dc73d838db66474e552cd5928de7f681a4e1fd45ecece1fb01fd01840885"
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
