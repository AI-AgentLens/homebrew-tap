cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.297"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.297/agentshield_0.2.297_darwin_amd64.tar.gz"
      sha256 "c71a11cc5b91654b9d045651d584d2d9acfc446c4fda4c4010378e71540fc022"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.297/agentshield_0.2.297_darwin_arm64.tar.gz"
      sha256 "a8c2779de2988226080f599303468b454586056227e2d236204f97659a0476e4"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.297/agentshield_0.2.297_linux_amd64.tar.gz"
      sha256 "a5f443e98bae3ea19739dded18ed71ba85df628648a7c89cd3a3fdaa6038a43f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.297/agentshield_0.2.297_linux_arm64.tar.gz"
      sha256 "d5aeaaf50bec982e6b2e6edb16498d8449874b68d4e2d1f56ef739d37c8c71ac"
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
