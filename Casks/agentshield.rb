cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1582"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1582/agentshield_0.2.1582_darwin_amd64.tar.gz"
      sha256 "543a1628035274389f3d5abc3c69f3a7359a9f8a8e590271998f1fb3a20c54e4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1582/agentshield_0.2.1582_darwin_arm64.tar.gz"
      sha256 "e77b08ce8683dc178535525a394bc10ee07b34945aca5f4b6c0143703dedb7a9"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1582/agentshield_0.2.1582_linux_amd64.tar.gz"
      sha256 "00848ecc9b0759244e564f64b08c2c375427b65d887af1ed9bec243b0df7286c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1582/agentshield_0.2.1582_linux_arm64.tar.gz"
      sha256 "1984c61065eca7e3e9fa39eb0b0a52f68c54269882fc615e358f961842fff33f"
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
