cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.301"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.301/agentshield_0.2.301_darwin_amd64.tar.gz"
      sha256 "e030823c39f365ae5ac51c72383f97befea59986a6c3de995119e90e0d73bba8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.301/agentshield_0.2.301_darwin_arm64.tar.gz"
      sha256 "3d429c25e5be26dab999dd424666663fe8f9f4d38e77cb089a83798ebf409a72"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.301/agentshield_0.2.301_linux_amd64.tar.gz"
      sha256 "a8c76dd8d0d56ae1d1388f4bf0dece03f3fadfdcf631f5948f264ff1815717d1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.301/agentshield_0.2.301_linux_arm64.tar.gz"
      sha256 "259c1347fcce737c58838446e73d8393fd1267dcf7bbe930ec3cb0c228b82828"
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
