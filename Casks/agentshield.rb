cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.490"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.490/agentshield_0.2.490_darwin_amd64.tar.gz"
      sha256 "f95dd6cb03a490ae5f25fa5cf64ae6079f25821911569ae8f7bd6fafff83490d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.490/agentshield_0.2.490_darwin_arm64.tar.gz"
      sha256 "9bbb0756ed8ed3d485df78fb75b9deaa5ef0178a331433230c6976d47fdb7b68"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.490/agentshield_0.2.490_linux_amd64.tar.gz"
      sha256 "4f81bb7fc026fe4f73d7a4368b40a5b22888385186ec40de8c87686cab062be2"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.490/agentshield_0.2.490_linux_arm64.tar.gz"
      sha256 "dbd55e2f6824c26a0237eb10792d70eece2f7497ae0e4d9efacad5aa2872d1ab"
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
