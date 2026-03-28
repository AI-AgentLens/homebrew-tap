cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.178"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.178/agentshield_0.2.178_darwin_amd64.tar.gz"
      sha256 "ff0497b256883928181904a7805aa93557cdb9dfcd1606df568d45b90a70d3d8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.178/agentshield_0.2.178_darwin_arm64.tar.gz"
      sha256 "46e69e55dc625ac2e2a8f6dd035b9497e0066f9307edf7cab03100291bae8766"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.178/agentshield_0.2.178_linux_amd64.tar.gz"
      sha256 "b4d2d77d97455be27709571fd0f1ee0f9464e60f911e2b3ab2a0d3ab1be85e98"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.178/agentshield_0.2.178_linux_arm64.tar.gz"
      sha256 "1062ce82096eb0f5edbd18b874bd51b6d928c8ac502b9080ff593698eaeaa76d"
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
