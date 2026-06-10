cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1271"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1271/agentshield_0.2.1271_darwin_amd64.tar.gz"
      sha256 "a9fde5a75fc551fea60623c5b42b2dce4935f296cf70eabbe24c886b0983ac1b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1271/agentshield_0.2.1271_darwin_arm64.tar.gz"
      sha256 "f8e73e34831012fee8c470692654c33ccb9ed8afdc2311610952758b9a016740"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1271/agentshield_0.2.1271_linux_amd64.tar.gz"
      sha256 "014416a1f876175220c85d50140efb6aff6378d219b89f75c5874685ea68016c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1271/agentshield_0.2.1271_linux_arm64.tar.gz"
      sha256 "e0c7018ee2bd8f9c6fcd2ff967303b0332c1826f255d7f8bf9545f6f2af41e3f"
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
