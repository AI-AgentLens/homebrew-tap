cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.461"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.461/agentshield_0.2.461_darwin_amd64.tar.gz"
      sha256 "8c25262b3ce85fb05eb4d6a337fd00c5087eab168e4a2cd0c22cdc5db1527863"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.461/agentshield_0.2.461_darwin_arm64.tar.gz"
      sha256 "bbc709a7f83310a813694147cda5bf73dcfbda2f8bcd894d60091c0552429959"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.461/agentshield_0.2.461_linux_amd64.tar.gz"
      sha256 "715fc0ef94ed4fc61a1bd8de9a5985c5d65a76656945606a15312448d0a30def"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.461/agentshield_0.2.461_linux_arm64.tar.gz"
      sha256 "c87fd737b4c3961db28ef1b7450eb4eb617e1dae1bd6f7292ef15993ddaec538"
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
