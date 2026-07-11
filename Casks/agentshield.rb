cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1615"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1615/agentshield_0.2.1615_darwin_amd64.tar.gz"
      sha256 "0856ff8166cec102177a58e845b6eae21fba0741a654623eeb8c281e41c1f36c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1615/agentshield_0.2.1615_darwin_arm64.tar.gz"
      sha256 "b5272c74e8e22e004e43f6262b373d171d69e593b2dc62ace8fb0c1174620aa2"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1615/agentshield_0.2.1615_linux_amd64.tar.gz"
      sha256 "5648732d1ab39efcf2831ca26b3bbe064656fdbce04cb1347f264ba567838173"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1615/agentshield_0.2.1615_linux_arm64.tar.gz"
      sha256 "456e90d30a5df41c4d024889a3e0df453fc860f8e6d91d30c06a25cf7c779ddd"
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
