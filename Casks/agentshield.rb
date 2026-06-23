cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1416"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1416/agentshield_0.2.1416_darwin_amd64.tar.gz"
      sha256 "ccbc01af59a0da039ea3d302743df3919bdaf71e7c5978122f74ea5c7f4e3573"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1416/agentshield_0.2.1416_darwin_arm64.tar.gz"
      sha256 "370f322e27eae77b63999e4046dd21b84946dcdfd488b46f949938ff057739d9"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1416/agentshield_0.2.1416_linux_amd64.tar.gz"
      sha256 "1d338e83f7277b5a60287d18a21922d54e41e697f8c292bad883a7cb707716c0"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1416/agentshield_0.2.1416_linux_arm64.tar.gz"
      sha256 "2ece75444e8c2df8002a391caa8e11543264e2a9c8ddf6630d18cd87e5c05158"
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
