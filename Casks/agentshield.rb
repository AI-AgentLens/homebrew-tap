cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.728"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.728/agentshield_0.2.728_darwin_amd64.tar.gz"
      sha256 "49ec8acb90578ac108a862d0e308086bd0fee1a67f65883a763fe8f7aa63be07"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.728/agentshield_0.2.728_darwin_arm64.tar.gz"
      sha256 "3e2066d5876ed76aa86c6179c14c1ca4f7a6837503ae57f01018e701bbe5191e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.728/agentshield_0.2.728_linux_amd64.tar.gz"
      sha256 "ee3ea27901587a5924b2b13c895eedb97123ce456fcc25b764a6d40dfe978de4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.728/agentshield_0.2.728_linux_arm64.tar.gz"
      sha256 "53a5cfbd6e0974299b48eb6c010a1002fb691094f78605c78177b78e8b736514"
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
