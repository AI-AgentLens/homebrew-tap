cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1268"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1268/agentshield_0.2.1268_darwin_amd64.tar.gz"
      sha256 "00ed5bea4567dcfb87a49941ef8879053558900d3e171719adfeccd38622c63f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1268/agentshield_0.2.1268_darwin_arm64.tar.gz"
      sha256 "c74bdbb1f45c5c3cdcd75a2526e6dba3d2330c85f8683e3f9c74e7354bba37b6"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1268/agentshield_0.2.1268_linux_amd64.tar.gz"
      sha256 "ed70b0bd5b3618f8e094f407b3462dd5c1936061efabefbb11571dcaf1bba3c6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1268/agentshield_0.2.1268_linux_arm64.tar.gz"
      sha256 "69100769166a2d3d61c9e45f2f3a2774ae9b3ecf249fd34c725fede6d575ed04"
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
