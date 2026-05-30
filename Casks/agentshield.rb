cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1152"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1152/agentshield_0.2.1152_darwin_amd64.tar.gz"
      sha256 "14b0e1f9b121e23b93d1c2679909e1fc4320487d0109779b7f531c53ead0347f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1152/agentshield_0.2.1152_darwin_arm64.tar.gz"
      sha256 "6be08846b9be7c42c9edcff72038eb64cba5dcbd365b5e9319d36c3a79397e7c"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1152/agentshield_0.2.1152_linux_amd64.tar.gz"
      sha256 "235be5630b15412f6ba8bc21d656e6cffe1c126cf41d02374fad58649d07c4e7"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1152/agentshield_0.2.1152_linux_arm64.tar.gz"
      sha256 "44683463435be3bfde8e9556e15ff69b6d4bd9c9e360e3f4d9eaf6a056032bfe"
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
