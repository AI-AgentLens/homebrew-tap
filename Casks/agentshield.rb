cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2103"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2103/agentshield_0.2.2103_darwin_amd64.tar.gz"
      sha256 "7e3b2417ab18e62dde2a19de2e65520bca41707e46efabac679bea98519f3fe0"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2103/agentshield_0.2.2103_darwin_arm64.tar.gz"
      sha256 "452122c7a55a1566a9a7a9723841360b22293765ff75f18e4312fca5dfb11f65"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2103/agentshield_0.2.2103_linux_amd64.tar.gz"
      sha256 "2f4ecfe6cb18a7db3ef919d208f911df3820dfdcab312a687e726e18190e3b07"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2103/agentshield_0.2.2103_linux_arm64.tar.gz"
      sha256 "040757fd0ba0899075969acc4c63b1036dce9134f356a2202af505ac521307ae"
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
