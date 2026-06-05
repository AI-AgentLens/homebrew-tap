cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1214"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1214/agentshield_0.2.1214_darwin_amd64.tar.gz"
      sha256 "c84184513c404c9e3a60ce79d7f38afa19338e8a7a35a0a59e2a0de455661a84"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1214/agentshield_0.2.1214_darwin_arm64.tar.gz"
      sha256 "c49d3fff5d8753a167ddcda1ee379d55bc380660208d64aefc888ea7109c6de6"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1214/agentshield_0.2.1214_linux_amd64.tar.gz"
      sha256 "dcecab21de60ae9d4b7dee176e2bd1aaeda3727498a0f3a4d489b44e62dc18b3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1214/agentshield_0.2.1214_linux_arm64.tar.gz"
      sha256 "a751b05472b15ae297e28f5306a8dbe058fd2a04cfc0c2114e9a4b74d1c4cadd"
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
