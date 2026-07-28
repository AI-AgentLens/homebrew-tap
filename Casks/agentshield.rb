cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1749"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1749/agentshield_0.2.1749_darwin_amd64.tar.gz"
      sha256 "07882bbb1f3256da9e48b98e24df47df535ee2b87be1f814b5d66af73b648130"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1749/agentshield_0.2.1749_darwin_arm64.tar.gz"
      sha256 "59b2ee93a0d7aec4b0b880381ab532c5d53209eef10d2105aa2b85523d845f92"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1749/agentshield_0.2.1749_linux_amd64.tar.gz"
      sha256 "d7d286342f37a8b2ba7f35c936935579d42ab9fe83d96a36fac2722b8fa0e73e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1749/agentshield_0.2.1749_linux_arm64.tar.gz"
      sha256 "2ba59e0bcdcc062c180d6b6f54ae939abc289ee3e88aa82f9601d100aa4b3ea4"
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
