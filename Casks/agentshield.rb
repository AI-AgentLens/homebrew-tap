cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1342"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1342/agentshield_0.2.1342_darwin_amd64.tar.gz"
      sha256 "edb408363099a1a6db7ea940c7e48790926bf98748d0dd9586f1b8002a188e44"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1342/agentshield_0.2.1342_darwin_arm64.tar.gz"
      sha256 "560f32079315fb6943343dc26d51265d9b2608bd5737edbe2a5003587aaf705d"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1342/agentshield_0.2.1342_linux_amd64.tar.gz"
      sha256 "5a80d1c5d57763266d9b078e8fc985cd473c5994e7758c084d61ebecf0d1debd"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1342/agentshield_0.2.1342_linux_arm64.tar.gz"
      sha256 "b2b4d53de70ed95785e2e95253ceda2b310796adb8c9f2372a31eee119a90e65"
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
