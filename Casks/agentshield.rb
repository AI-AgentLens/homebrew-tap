cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2382"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2382/agentshield_0.2.2382_darwin_amd64.tar.gz"
      sha256 "d469014b79fc8afafecb3eb212b95e3f14b2bd02ef9055239c185fa71e38ac92"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2382/agentshield_0.2.2382_darwin_arm64.tar.gz"
      sha256 "0fc2a73ed9e9aff11220dbb4bae97c0f4e9ed27c4e57219df47b260ab74300f4"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2382/agentshield_0.2.2382_linux_amd64.tar.gz"
      sha256 "a2fb89d1eb13e4104ecf66223f0aa2c7eb03efdd4ee94832b8c4ed584e646043"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2382/agentshield_0.2.2382_linux_arm64.tar.gz"
      sha256 "995958d0dae9da175df2e6624fe27f845d4f3301d036322cc76d1688d1148d1e"
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
