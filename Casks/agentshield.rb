cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1920"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1920/agentshield_0.2.1920_darwin_amd64.tar.gz"
      sha256 "177961b4263a1eec8bba9ca43cd1889b4463bd53a0b38ad121465886a0acf415"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1920/agentshield_0.2.1920_darwin_arm64.tar.gz"
      sha256 "2342e0bacf3a511e7e454d388188f39b6f8c66d3a9e60f4a151ac4ae1469d706"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1920/agentshield_0.2.1920_linux_amd64.tar.gz"
      sha256 "a8b4b21b68ed465cb544c7981f9a4832241ced7546c81603c03646192a388f90"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1920/agentshield_0.2.1920_linux_arm64.tar.gz"
      sha256 "980aae50d49bc4c578c7060187d5f90934d1bf620f6e9a35976065852a5f7872"
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
