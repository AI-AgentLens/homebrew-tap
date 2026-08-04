cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1787"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1787/agentshield_0.2.1787_darwin_amd64.tar.gz"
      sha256 "8c7a221398020a314c0766d4f88a4191bdb59139b01afa17906b33c0f8790bdb"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1787/agentshield_0.2.1787_darwin_arm64.tar.gz"
      sha256 "7f0089787c5a06203f3d24ebf417fa7238651cf447ad793c9ae6bda353283174"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1787/agentshield_0.2.1787_linux_amd64.tar.gz"
      sha256 "45e66e0f846216816ad1c1f7f4c1d1a678cb82504b7876eb709c011039ee2a4b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1787/agentshield_0.2.1787_linux_arm64.tar.gz"
      sha256 "8fb3bcfa5669cd3276e071e8eccaa6b2eeb6d89fdee4a7bb48b74ea99ad80255"
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
