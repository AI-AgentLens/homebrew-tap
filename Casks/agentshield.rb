cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2149"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2149/agentshield_0.2.2149_darwin_amd64.tar.gz"
      sha256 "3082024093a6e677e0e69b4ccb79de681c9daab2a4702215c60adcb1dcedf38d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2149/agentshield_0.2.2149_darwin_arm64.tar.gz"
      sha256 "5f8959db0389f504f7bc46bfd09aa2605b965a865703aa5677fc5dceef030651"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2149/agentshield_0.2.2149_linux_amd64.tar.gz"
      sha256 "8995fb1f49dfb6363185ec2f888f9ed129aff13db4482934d8b8b178372af8ef"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2149/agentshield_0.2.2149_linux_arm64.tar.gz"
      sha256 "1e49931902b7b4e66cbf19349e3b38d52815afde1538ac6fcff298845dc1f2da"
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
