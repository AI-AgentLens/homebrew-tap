cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2292"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2292/agentshield_0.2.2292_darwin_amd64.tar.gz"
      sha256 "7ca5e40c65874d5989beb9fc859af52b0a028f54d96acc090f2a9cb42f3b22eb"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2292/agentshield_0.2.2292_darwin_arm64.tar.gz"
      sha256 "fab4441f56938a2f514fee6ab62d9b737ca85b1dba2761f57111da30c70110f3"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2292/agentshield_0.2.2292_linux_amd64.tar.gz"
      sha256 "1fc5805ecf6c5f214e2ec03bf459a7efff321f6c69b3fb1d401c9ab464960ada"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2292/agentshield_0.2.2292_linux_arm64.tar.gz"
      sha256 "ee25ced15af7666f1b0e8cd4a38ba1a9bd807713a7118d261bd709c43a03d0d8"
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
