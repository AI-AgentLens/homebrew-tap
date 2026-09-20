cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2199"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2199/agentshield_0.2.2199_darwin_amd64.tar.gz"
      sha256 "cb3d3eec6756c14df4e90466cd25501a8d14fff54f8d81aacfc9aad0a4154399"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2199/agentshield_0.2.2199_darwin_arm64.tar.gz"
      sha256 "9648b9fab1fda36743855a4383ac5ec1bf141e631f3238e727d092d27148cfae"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2199/agentshield_0.2.2199_linux_amd64.tar.gz"
      sha256 "c13abcb46cf53a29b21bffe9f98efc0e7db8d16ec29a4519ae49ec9f45da9319"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2199/agentshield_0.2.2199_linux_arm64.tar.gz"
      sha256 "7fa3ccb408d3b51b44fc33873e72f4e4be4b99fdc04abbbde6d1a2205628fbcb"
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
