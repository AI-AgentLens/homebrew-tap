cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1259"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1259/agentshield_0.2.1259_darwin_amd64.tar.gz"
      sha256 "59711cee56a680124f53724b814a923017c6b30d231a86ac9a6f453a89553e56"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1259/agentshield_0.2.1259_darwin_arm64.tar.gz"
      sha256 "1658e99900f6c54356ac6cbc0c56f35681557671b7ed4a26497d053144c4aaf8"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1259/agentshield_0.2.1259_linux_amd64.tar.gz"
      sha256 "855f1a7ec567f720ee7980cef6157dbcf09a2289d330aa82ce6c1538bc1bc75e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1259/agentshield_0.2.1259_linux_arm64.tar.gz"
      sha256 "38f0456f3d091150f8b8dda39462d2e8706de0b0bcf471e24e3fa36358d52ca7"
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
