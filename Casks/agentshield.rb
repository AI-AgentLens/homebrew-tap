cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1198"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1198/agentshield_0.2.1198_darwin_amd64.tar.gz"
      sha256 "5895531023e6dc4c3c16cb676379e949671aeb042d082ef12d6a3c9786aa46d9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1198/agentshield_0.2.1198_darwin_arm64.tar.gz"
      sha256 "1e5e1b6840e2f00a58f2126cc325df4cb3000d33a2fc21564b45a4aa07fe4e57"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1198/agentshield_0.2.1198_linux_amd64.tar.gz"
      sha256 "840406196dcdcd1a5f4358c88d4683baaad9bf1a6280c065e5775fccae17e006"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1198/agentshield_0.2.1198_linux_arm64.tar.gz"
      sha256 "b758c3cead82c23ec9ad56e44eacdc90c62cad49f8b6ab5e0ac7f5f2f57fa8c3"
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
