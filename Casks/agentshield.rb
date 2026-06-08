cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1245"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1245/agentshield_0.2.1245_darwin_amd64.tar.gz"
      sha256 "648255d9b7c1b4d41917744fc9745f86ebc6f96d614b6aa4d3d8baff908a9e38"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1245/agentshield_0.2.1245_darwin_arm64.tar.gz"
      sha256 "88a8632f38dfa1240da105d84cf5f9d83dbd8e8c9a3e1cc1393cf5bb310a6fc7"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1245/agentshield_0.2.1245_linux_amd64.tar.gz"
      sha256 "6e65cd83cd0a4dd45b613a9eed433e63625f0a44c3f77663ef62360c9bb7f7a1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1245/agentshield_0.2.1245_linux_arm64.tar.gz"
      sha256 "98854183f865dfc04e3f780ad828ce7cc5cf2d9eb2e90f61df770acfa9e3a7e4"
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
