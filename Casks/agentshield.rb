cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.134"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.134/agentshield_0.2.134_darwin_amd64.tar.gz"
      sha256 "7a4ee5072e1babdede20bf55904c9488e2d7bd63214ba91a63fd24dc322a9d3b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.134/agentshield_0.2.134_darwin_arm64.tar.gz"
      sha256 "0bb5372a70a2c0eaa53bed417776a3687646d346c02cb13d944c015661052934"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.134/agentshield_0.2.134_linux_amd64.tar.gz"
      sha256 "2b30d9e0513abfbd17b2e659428303b08a666ef62e76c534e138b5cde265bd35"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.134/agentshield_0.2.134_linux_arm64.tar.gz"
      sha256 "e9842fc9e1825872f314d30f33d76f8819d013d06aef1a02381573409fd4e27a"
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
