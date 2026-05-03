cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.859"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.859/agentshield_0.2.859_darwin_amd64.tar.gz"
      sha256 "0c423d059f2f05aeb23a38f83417b22b538efa7a860507fb4572ccfe7af5df47"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.859/agentshield_0.2.859_darwin_arm64.tar.gz"
      sha256 "946651c9cbf6915e6a61ebd9542078f2a490c9f2ab42d74f0862df55528af9ae"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.859/agentshield_0.2.859_linux_amd64.tar.gz"
      sha256 "7dca98152b9cd5db333c7b26b88691e9eeda27ec8ba83091395adf795a2f3f82"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.859/agentshield_0.2.859_linux_arm64.tar.gz"
      sha256 "754fafb7025a6e6bcbe7cb2cacd1065c7368158057a8950f0705b66ed148b126"
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
