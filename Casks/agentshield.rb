cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.92"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.92/agentshield_0.2.92_darwin_amd64.tar.gz"
      sha256 "042f459f074727693bb1691cd92b6cf978a849d050b639cac700da41095da70b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.92/agentshield_0.2.92_darwin_arm64.tar.gz"
      sha256 "a4be20d91c0ee172dfbea53f6d0ca2faa8f81d5f2dab54a07b4dcab64aa96dfb"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.92/agentshield_0.2.92_linux_amd64.tar.gz"
      sha256 "aa7754da8cee5b3baf1e80e3671513ea715260631a131898bbf08624b49a06c3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.92/agentshield_0.2.92_linux_arm64.tar.gz"
      sha256 "177441011d05bd55e0dfcad1f4a5210730948a382ab913fe962623da777291cf"
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
