cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1932"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1932/agentshield_0.2.1932_darwin_amd64.tar.gz"
      sha256 "665dacf5218aa4a285e69c5efbe6eab706e29158f1463c5d4d35bbcf2835a60c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1932/agentshield_0.2.1932_darwin_arm64.tar.gz"
      sha256 "9c31b842cfa64a12bf7292e442f778d559f2616aeee1f9137c8a0073624ced64"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1932/agentshield_0.2.1932_linux_amd64.tar.gz"
      sha256 "898b001a05d2d4172eb61ad6a8db202d9e2bd4af385cc3c8473b372716ad0506"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1932/agentshield_0.2.1932_linux_arm64.tar.gz"
      sha256 "6e7d546a966c8152b5a3b05f21f6292cd7fe1a75f68f581ac29a4c0f0d8ba528"
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
