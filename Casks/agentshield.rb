cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2211"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2211/agentshield_0.2.2211_darwin_amd64.tar.gz"
      sha256 "656850b889e1da917c52473f2cca1a53a70005eca79576ca113753252f32a28b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2211/agentshield_0.2.2211_darwin_arm64.tar.gz"
      sha256 "f2b9a9df29935dc967e8735c4261f3c7404d2e3c84907d71076be72f9ee37f6d"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2211/agentshield_0.2.2211_linux_amd64.tar.gz"
      sha256 "68a79761a3dc668a6c339d21be9f98a53c18ab4dd6fc8a0f5b6e834486e28fc4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2211/agentshield_0.2.2211_linux_arm64.tar.gz"
      sha256 "024056e15b8c8c801738fc9d905f771e84f852452f15fdbff13f385aa25f56d1"
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
