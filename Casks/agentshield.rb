cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1838"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1838/agentshield_0.2.1838_darwin_amd64.tar.gz"
      sha256 "22ef56419737d8ac8f991a96ef78acdfea50fa5b21ba689c6e94967163b1f198"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1838/agentshield_0.2.1838_darwin_arm64.tar.gz"
      sha256 "c2b2eef3e631ad2c8acad908fb6285fab39934e4a7a120e28080a33af0469134"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1838/agentshield_0.2.1838_linux_amd64.tar.gz"
      sha256 "bdb1bf39aaa3419c81ff85f9e872088f4dc385ed25a9d4f94300f5e7ac2cff39"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1838/agentshield_0.2.1838_linux_arm64.tar.gz"
      sha256 "13ae746249ec8051439880add6577af5f98b8b320be98e37b3a2da84827c14d7"
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
