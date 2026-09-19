cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2183"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2183/agentshield_0.2.2183_darwin_amd64.tar.gz"
      sha256 "36838e94986fb08803c5392045362d6318fa89a0133ab8137a30cf535e6183e5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2183/agentshield_0.2.2183_darwin_arm64.tar.gz"
      sha256 "b9ce30b82ae35b2fe86129e95c6f4d486900405d2c7c6c3fcd04f4449f8b2ec1"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2183/agentshield_0.2.2183_linux_amd64.tar.gz"
      sha256 "44975d2a62448d17dc5cc3cef937721e166e9c23a7dda30705ab47a94d3f6e21"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2183/agentshield_0.2.2183_linux_arm64.tar.gz"
      sha256 "1828278db789b5686e52ec498f37e10fd78582be69a7a9e2c509ebcb5b0f7a8a"
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
