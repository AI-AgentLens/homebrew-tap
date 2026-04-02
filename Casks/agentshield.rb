cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.316"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.316/agentshield_0.2.316_darwin_amd64.tar.gz"
      sha256 "e37e4f2ce0a7a931c26b1ebd62d694c9a7b11581d8bea1d4490d88bf1afce367"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.316/agentshield_0.2.316_darwin_arm64.tar.gz"
      sha256 "ba97fb8506fc4375bbe5c55981d924264e8dd3468b502d27f8e6b6806e8fcb11"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.316/agentshield_0.2.316_linux_amd64.tar.gz"
      sha256 "80f30c3fcccc088d21893d56f35e30cbe95f64020ee25dbe890dcfad5ea342ec"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.316/agentshield_0.2.316_linux_arm64.tar.gz"
      sha256 "f11dbb860d4aa6d3a7edc12c2d435eb743e5baddeb2814b8644e22200e97192b"
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
