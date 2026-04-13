cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.579"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.579/agentshield_0.2.579_darwin_amd64.tar.gz"
      sha256 "c2211290b2ea66fb035a5dc7dfc3db8454853f13facf4dd77fc93210966bb4f8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.579/agentshield_0.2.579_darwin_arm64.tar.gz"
      sha256 "56942cd88811fd4656ea9b0b321b69c66f1e82e617494086028eff1532ac2a0c"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.579/agentshield_0.2.579_linux_amd64.tar.gz"
      sha256 "fc19968d2dcc8969018f570a19485570e1fbae919c69531428c2b9b4946c6b05"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.579/agentshield_0.2.579_linux_arm64.tar.gz"
      sha256 "3ec20686a2067f47fb931829f13b4b080dc74dc18e3b0dad5dbbd91353cf89bf"
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
