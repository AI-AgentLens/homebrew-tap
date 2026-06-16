cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1327"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1327/agentshield_0.2.1327_darwin_amd64.tar.gz"
      sha256 "df537fd9c49764afd0f06a273d7df6ecd682ba44956669d7215fe89760320a4e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1327/agentshield_0.2.1327_darwin_arm64.tar.gz"
      sha256 "39cdee67991d2dcad9a7e44e8beab1abdefbb74e014001a8bdd7a82052bd86ff"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1327/agentshield_0.2.1327_linux_amd64.tar.gz"
      sha256 "c5fd8bea1b577b765a95694435a4e27fcea342b8530c701d571f2c529f87eb0d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1327/agentshield_0.2.1327_linux_arm64.tar.gz"
      sha256 "72f92f16baff8c635357bac776177d78339b1eac21ee613f0993982ed197981b"
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
