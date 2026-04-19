cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.655"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.655/agentshield_0.2.655_darwin_amd64.tar.gz"
      sha256 "2b1d83a288aa21bde5b30610f47367e35716c143d3863d6c79d00c1c2bda35a1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.655/agentshield_0.2.655_darwin_arm64.tar.gz"
      sha256 "450b4e69b9622fc2f49f6cf02dfe0eb3ed9cd5c5cb12c96a911dd427133863f5"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.655/agentshield_0.2.655_linux_amd64.tar.gz"
      sha256 "3dd41a46bb2d2c6374a8104cd457b0689e660d9527b739b186bf42254aca6c79"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.655/agentshield_0.2.655_linux_arm64.tar.gz"
      sha256 "30f1ddd9745c6332917343b054a0cec4cb9f6db173051a72670112d0e2065a71"
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
