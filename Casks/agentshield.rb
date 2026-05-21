cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1055"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1055/agentshield_0.2.1055_darwin_amd64.tar.gz"
      sha256 "868c53c6aca11cf30665b09c707cc7f5d36e58517f97a53c6f0f831a41700c1f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1055/agentshield_0.2.1055_darwin_arm64.tar.gz"
      sha256 "525bf733f9843d2ed5ab4ee130dea3a7e47ec306f365f60320556fa4674fae8a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1055/agentshield_0.2.1055_linux_amd64.tar.gz"
      sha256 "5a0d8fb3dcf544a0cf042051f5247097cd6004bb90b880cfb48cb5d2ef38b1bf"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1055/agentshield_0.2.1055_linux_arm64.tar.gz"
      sha256 "56f70e908188d13c47c330d1232422fb8db6733e174f3cb130ec3ee918dcac3f"
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
