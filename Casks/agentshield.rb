cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2132"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2132/agentshield_0.2.2132_darwin_amd64.tar.gz"
      sha256 "b0e6dd1fa3769708b84a2e8b70891e82aea805ba7e450834d52b9b685fc99695"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2132/agentshield_0.2.2132_darwin_arm64.tar.gz"
      sha256 "1232366d2f130c11c75d2c11a1676ee7ebce581d8ece7f25b8eaaf113ffdf8a8"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2132/agentshield_0.2.2132_linux_amd64.tar.gz"
      sha256 "49ad1057ccb2173306e3c684baea8a72cf24418cc61e997a2983177fc9d257e3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2132/agentshield_0.2.2132_linux_arm64.tar.gz"
      sha256 "5f6f30befa8ecbf680d8c463427e8711045e789b356966b2a08b2d2662c68e29"
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
