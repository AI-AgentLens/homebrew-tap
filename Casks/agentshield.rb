cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2203"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2203/agentshield_0.2.2203_darwin_amd64.tar.gz"
      sha256 "3d08b3806da278c9597bc461c71037f03613359a5832129b464ed846f7b6589f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2203/agentshield_0.2.2203_darwin_arm64.tar.gz"
      sha256 "d4b7477a3d52bd961aff2f8a099708188531ee2f1152b7370e804f941923747d"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2203/agentshield_0.2.2203_linux_amd64.tar.gz"
      sha256 "59ecf2b6ffc82090e91521300ba5f8f45e18e683fa5e6ca9b8274cfc269708bb"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2203/agentshield_0.2.2203_linux_arm64.tar.gz"
      sha256 "18537dae9ba96b36ff382eacd8817acac292e6c9569cd84ec68d02e4f2a34137"
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
