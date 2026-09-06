cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2062"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2062/agentshield_0.2.2062_darwin_amd64.tar.gz"
      sha256 "f71a89ed4959dcf43c490aa8a9f291a55216ad95b271ceef4963882dbdea73d1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2062/agentshield_0.2.2062_darwin_arm64.tar.gz"
      sha256 "a1ce4969bf6bf492a9261bd101e26835ebaa2cd4a8512877eb7bc7389c857d98"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2062/agentshield_0.2.2062_linux_amd64.tar.gz"
      sha256 "9c64551dca1f8994684175b83a8be118e34f78b30e6984e3534dfe694ea62ba3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2062/agentshield_0.2.2062_linux_arm64.tar.gz"
      sha256 "39034a75558f286659b896f7ee9216500c8a5a8a23c41cc262143eaf3f924dd3"
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
