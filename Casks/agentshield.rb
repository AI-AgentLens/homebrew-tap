cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2300"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2300/agentshield_0.2.2300_darwin_amd64.tar.gz"
      sha256 "4d2d61e146bd7bd0070ddc2598afde688ad8f4c03751ea12f97d9d068c4c47d5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2300/agentshield_0.2.2300_darwin_arm64.tar.gz"
      sha256 "ab5a5807dba38c8a16d5303ce74963656c21ae2d39546a9535f434dc0611a3d7"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2300/agentshield_0.2.2300_linux_amd64.tar.gz"
      sha256 "6dd567102729d99eb286666e238b5a8d876a4c3eea399a5cdc5f27cdb0c90258"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2300/agentshield_0.2.2300_linux_arm64.tar.gz"
      sha256 "e2678a7ff8707ddfe5c5846417491c836f2022b1aefd7dee5ca3ae590b8240e4"
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
