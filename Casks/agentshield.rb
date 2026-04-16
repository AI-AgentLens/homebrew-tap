cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.616"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.616/agentshield_0.2.616_darwin_amd64.tar.gz"
      sha256 "5dc7a08ef31134d1478cba0dbe07fae3c59c677e477b3cedb11aef084b004e26"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.616/agentshield_0.2.616_darwin_arm64.tar.gz"
      sha256 "93d59def3f9fd0a220422d47b23c780cc4b20753f7e3fe119966918befbc02bb"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.616/agentshield_0.2.616_linux_amd64.tar.gz"
      sha256 "79ee31cc9ac2d69be62817ee8fcefc3625fa5fa1a05a7940981aa467dc74e6c5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.616/agentshield_0.2.616_linux_arm64.tar.gz"
      sha256 "422c35bfc41f58dae9fad171fa2ec7a1caf10da5bb69b2f1c8640cae761e748c"
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
