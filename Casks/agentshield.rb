cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.759"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.759/agentshield_0.2.759_darwin_amd64.tar.gz"
      sha256 "eb93a827508b767d058950e5a08f13795b6b442a9186a7fec076bf0cda500584"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.759/agentshield_0.2.759_darwin_arm64.tar.gz"
      sha256 "be2d8e37061d90f55bdb3fc0882dc076965ff05033da96ac78d267c9c7cc1f02"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.759/agentshield_0.2.759_linux_amd64.tar.gz"
      sha256 "fe27a5f6917fadc5f7e833f46fdb721f0b609d8392c267aa5bbe15ddafc98a4d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.759/agentshield_0.2.759_linux_arm64.tar.gz"
      sha256 "56cbad9d89ab0ea94b95f404db9b0f2e2f72d7a7a4aba63042c7a74f642ec987"
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
