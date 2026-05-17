cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1010"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1010/agentshield_0.2.1010_darwin_amd64.tar.gz"
      sha256 "8bce94cdb663bc486eb5618f6708f3a5dc279eb7bba49f195ac707bd85ace966"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1010/agentshield_0.2.1010_darwin_arm64.tar.gz"
      sha256 "d1c7dd7f29f10769570ca5a72cd9b9ad4975cc8b62cc375966591f7f0e275030"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1010/agentshield_0.2.1010_linux_amd64.tar.gz"
      sha256 "66e0bf91993acb9d3db291496ea79f9a9c32eb7fc34078b85f0d3f8214df47db"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1010/agentshield_0.2.1010_linux_arm64.tar.gz"
      sha256 "7bebf7d3f7882ccc1f7b65d42ff4c46a60d31830aad920414030d70db8677de7"
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
