cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1987"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1987/agentshield_0.2.1987_darwin_amd64.tar.gz"
      sha256 "843ae1e08520f271adfccb66cab587cada9294dda6da53e6f6928c9be158d6b5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1987/agentshield_0.2.1987_darwin_arm64.tar.gz"
      sha256 "6baff037736399eb25a426aca83146a1ffd9bde6ebeb0267a5f2ed6a3ce4c2aa"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1987/agentshield_0.2.1987_linux_amd64.tar.gz"
      sha256 "858a99d0f094304e7ffee144a3a2340e833a4cb50a5dfcbfd922464cc24f04ae"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1987/agentshield_0.2.1987_linux_arm64.tar.gz"
      sha256 "08bd3347d80a36886e4d26f3eddfeb832e0a116d7a51aa54c202b569702b8c9d"
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
