cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2221"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2221/agentshield_0.2.2221_darwin_amd64.tar.gz"
      sha256 "920c09aec3f4edba3f914b67bdd9941d24988b65fc7a151607f42c5aeae6b6b2"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2221/agentshield_0.2.2221_darwin_arm64.tar.gz"
      sha256 "17d883f30433c6e1357559911b58ce108211620eb87b53f430bfb905bd38a096"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2221/agentshield_0.2.2221_linux_amd64.tar.gz"
      sha256 "2c671a3613e5fb90bc7d001f1d92ac41da2e70d626bec1dee397c044e7156776"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2221/agentshield_0.2.2221_linux_arm64.tar.gz"
      sha256 "ec64172a0d3493bc23d3a0cf09849a82a704268b4f60562064d604aa4b2069ba"
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
