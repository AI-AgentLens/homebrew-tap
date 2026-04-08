cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.498"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.498/agentshield_0.2.498_darwin_amd64.tar.gz"
      sha256 "468bb4eacb5e459d58f42f30cad0e3be5078895b572137f1d1c2185cc887b4bc"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.498/agentshield_0.2.498_darwin_arm64.tar.gz"
      sha256 "39c31e892d183efc56d790ff0a3fd0967b8a62328018693ca93aa7d3782be996"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.498/agentshield_0.2.498_linux_amd64.tar.gz"
      sha256 "9e5560ca3b634ebd1dcf9dbb1f04797e11fb2348ae35dee6127355ce31afa445"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.498/agentshield_0.2.498_linux_arm64.tar.gz"
      sha256 "006b9a38bcf549f0c46335c3eb978978181fa8fc78b399d8a2d64452b1c5c2ff"
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
