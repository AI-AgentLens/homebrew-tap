cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.154"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.154/agentshield_0.2.154_darwin_amd64.tar.gz"
      sha256 "f3fa7e70b8d4a8d57f07244e6d876f98dd81e949a9d5632aee4de3020cd8efaa"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.154/agentshield_0.2.154_darwin_arm64.tar.gz"
      sha256 "8c63e1aa6bb9f4e87ad96106d8fb976f7592e84f6c3f2f4436e7f0bb1cd16f02"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.154/agentshield_0.2.154_linux_amd64.tar.gz"
      sha256 "504ab4e2a3ee91b8d18ab61a0715cf353defbcd85f9163cc60fcd2f5866b1f8f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.154/agentshield_0.2.154_linux_arm64.tar.gz"
      sha256 "e9595e5c4a9a769124ca9fe52486a38bef264536055ccd1c904a63f01136d06b"
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
