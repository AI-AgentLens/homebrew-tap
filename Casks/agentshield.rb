cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.157"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.157/agentshield_0.2.157_darwin_amd64.tar.gz"
      sha256 "95a48d7e952e446673e10cf2bb843ac7c802083e5dc75cd43b6ebf21a58e1c69"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.157/agentshield_0.2.157_darwin_arm64.tar.gz"
      sha256 "99ad63015aa2f7c5e2bac98a096faa248fd0cf3b75288b1ddca85f8f9e4aab09"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.157/agentshield_0.2.157_linux_amd64.tar.gz"
      sha256 "ca1e92fe73cf887afa1c4fd376fe53e6393f72400eb11aba2661db8ee8292d23"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.157/agentshield_0.2.157_linux_arm64.tar.gz"
      sha256 "8f4456896629d5e706d1d78e3d93935a831c87fec71eed25723c638ba9e7e42f"
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
