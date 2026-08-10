cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1812"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1812/agentshield_0.2.1812_darwin_amd64.tar.gz"
      sha256 "cd8b790ea994d4531e3920de829cc3a3d8bccfcb71f4e958f646e88680187dd4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1812/agentshield_0.2.1812_darwin_arm64.tar.gz"
      sha256 "6e3a3209122092eed75aff06011b5deac50abdaa259b14a3f0572e209841f5da"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1812/agentshield_0.2.1812_linux_amd64.tar.gz"
      sha256 "b5a48fcd30eb55649a19da5b8933fc9c4907877841b02b91d69a561702951740"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1812/agentshield_0.2.1812_linux_arm64.tar.gz"
      sha256 "28538cea9c364f60f42424014e39cc05d660901581a33078fec69ccdecb339b8"
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
