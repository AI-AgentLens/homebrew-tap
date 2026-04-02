cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.325"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.325/agentshield_0.2.325_darwin_amd64.tar.gz"
      sha256 "d2da1bd12aa46a58581c83adc72a48ba00aeb7d715c7fdb8cc8d03a76607d817"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.325/agentshield_0.2.325_darwin_arm64.tar.gz"
      sha256 "9f06e5f8cb1fe3dd39b24f78e3c99b9634a5adeb329efc356f36bd5c8868f2c6"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.325/agentshield_0.2.325_linux_amd64.tar.gz"
      sha256 "c87db16115701572d571e7b015bd76ce6d19e30f61167e94fa303368e97013a5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.325/agentshield_0.2.325_linux_arm64.tar.gz"
      sha256 "e5c90e6ddf7af1d536c859695ee3f2a1fddbaa5bcfddc3fe505ad0cdb034c4d9"
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
