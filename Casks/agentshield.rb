cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.515"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.515/agentshield_0.2.515_darwin_amd64.tar.gz"
      sha256 "4de5cf42a200ad17aecabd5f2eda82dcc655dcd9e39aad897e3d8378356d5b20"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.515/agentshield_0.2.515_darwin_arm64.tar.gz"
      sha256 "56426f79caeb133718932b4381e662174ff712546c1541b07c0c22af8aa3c1c6"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.515/agentshield_0.2.515_linux_amd64.tar.gz"
      sha256 "7ae50d65ea935f2971af67ee600f2335db233d0650756ea7f015001538f7b79e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.515/agentshield_0.2.515_linux_arm64.tar.gz"
      sha256 "57911177df1e4d99493e1a7ef6efd0920c26b38e8f738a5775f29bdcd85f2319"
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
