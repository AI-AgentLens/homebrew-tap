cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1438"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1438/agentshield_0.2.1438_darwin_amd64.tar.gz"
      sha256 "0dff08c176cf79fd31dc179a354695d0e9abb08ca481b3b3065455834be11249"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1438/agentshield_0.2.1438_darwin_arm64.tar.gz"
      sha256 "99d3cbd31d46f4fe1139bfbec1175bf41d792aed7f3ca59c828d91127f13ff0b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1438/agentshield_0.2.1438_linux_amd64.tar.gz"
      sha256 "4e0313e111ff36fce72c44cd8708e90f73e83bf51dbd7894ab45e64547457aaf"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1438/agentshield_0.2.1438_linux_arm64.tar.gz"
      sha256 "e1d6590de3c55dbb106f92ca55e67bb8ebe3c4b3afa4c1737ab7ce6adf11f3ea"
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
