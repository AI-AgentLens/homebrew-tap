cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1778"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1778/agentshield_0.2.1778_darwin_amd64.tar.gz"
      sha256 "679542b0c89e9ef396a01c35f258c5336f5b97134052fb12d4e3dc76d19341cd"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1778/agentshield_0.2.1778_darwin_arm64.tar.gz"
      sha256 "2950671dba3303fdab6f6e8e96417a337e2911664d85f13f7deefb6a24e2ad0b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1778/agentshield_0.2.1778_linux_amd64.tar.gz"
      sha256 "69b588e60e3c840dad81015cc59a0ecf777a54023c1d3bf87752b5d652fbeed5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1778/agentshield_0.2.1778_linux_arm64.tar.gz"
      sha256 "2c957cee60f3858f10f86af24fc0102996067f5e52471f13d597ec114452c71a"
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
