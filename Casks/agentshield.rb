cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2110"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2110/agentshield_0.2.2110_darwin_amd64.tar.gz"
      sha256 "108bf5c85ae86acdeb2e5e400db7c6b142623326af017f0d9b173cd6b837cebd"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2110/agentshield_0.2.2110_darwin_arm64.tar.gz"
      sha256 "9189ae7100e1f9fad7a9738dd1d13c0382666f4c1b08ed166978016e64024fe1"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2110/agentshield_0.2.2110_linux_amd64.tar.gz"
      sha256 "4544a1d3dfad5e2858dbd8dfbf59ce59b24df6395ecf132b51a4fe1074741fd9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2110/agentshield_0.2.2110_linux_arm64.tar.gz"
      sha256 "894d47fe5f7ad6545243ee8c7892c9b60d15dd616c4759c65ece49a2fff42e4b"
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
