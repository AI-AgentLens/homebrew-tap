cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1440"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1440/agentshield_0.2.1440_darwin_amd64.tar.gz"
      sha256 "b4d43c97fa42776c481bf0519d3d6b50e0b36e8a16be85bbfa16f1a6627968c6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1440/agentshield_0.2.1440_darwin_arm64.tar.gz"
      sha256 "b63261d898446483d97f9edba0ed25eb064fa9f7f9253c090e1052befd4bfdd8"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1440/agentshield_0.2.1440_linux_amd64.tar.gz"
      sha256 "f469dafe279b3639d8fe3376a79b1ac114fd6aee17bc53ad6e211f87531f6122"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1440/agentshield_0.2.1440_linux_arm64.tar.gz"
      sha256 "02fdcf6193fcd277f04a2e0ec247c99691720df415dacfb80cd1105e508ef75e"
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
