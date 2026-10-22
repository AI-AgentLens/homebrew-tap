cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2500"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2500/agentshield_0.2.2500_darwin_amd64.tar.gz"
      sha256 "c9c1ed02aef7577ada3badd7952cf1f6ec25eb26a47865ac3e4d26d90d4bbb3c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2500/agentshield_0.2.2500_darwin_arm64.tar.gz"
      sha256 "71b0ed12d8aeb0e1b0cbc133fffb2219ff3b9a5e97df44fcd15bb42067d99cf4"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2500/agentshield_0.2.2500_linux_amd64.tar.gz"
      sha256 "77bf8bb5d6a6d62c41b84c3cdfb9fc66bf9899b2a6967e58af759a5e942fc406"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2500/agentshield_0.2.2500_linux_arm64.tar.gz"
      sha256 "1dd6f611c41b487f2190a1de3c13e11710c84f35064e730e0ed2ca96001212c5"
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
