cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.554"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.554/agentshield_0.2.554_darwin_amd64.tar.gz"
      sha256 "7190f256229eb25fc259f4f44ad798668f7ed1f98571cdbdfecb71141b1bfbbb"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.554/agentshield_0.2.554_darwin_arm64.tar.gz"
      sha256 "c0a570690989cbb147a749cd3aa626d10d8c41d1a952f7c18fb2553f9a42bd99"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.554/agentshield_0.2.554_linux_amd64.tar.gz"
      sha256 "2fe632126949b184255f204850cdf7c9bfeb692d98a93151a471923a617da6e3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.554/agentshield_0.2.554_linux_arm64.tar.gz"
      sha256 "411f92ea3e4d5efe8253688c3dfc2533300b1b8a315db73b0d6207ce063e78f3"
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
