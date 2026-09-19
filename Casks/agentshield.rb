cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2184"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2184/agentshield_0.2.2184_darwin_amd64.tar.gz"
      sha256 "4bd2c58645517bebc3785482049f03b5e7fc1969869063612152a369479e7ab9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2184/agentshield_0.2.2184_darwin_arm64.tar.gz"
      sha256 "2dfa5018b740218d0028bfa751a5784a477dd0929d7cf906d0f1c772f676f285"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2184/agentshield_0.2.2184_linux_amd64.tar.gz"
      sha256 "eda8f9072ce25c62eebab5536a5de7f76aefe7835f815df47825d4d30f486221"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2184/agentshield_0.2.2184_linux_arm64.tar.gz"
      sha256 "93c152227c52410adc2183a86b4efbd8e3ba2b3d059cc08cd1ae4075928f3c37"
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
