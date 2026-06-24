cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1436"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1436/agentshield_0.2.1436_darwin_amd64.tar.gz"
      sha256 "9e50962b9801eefda0f04a5563833af19d06937efb2c519129c43312645f0873"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1436/agentshield_0.2.1436_darwin_arm64.tar.gz"
      sha256 "07624224d5bfecf5538df140b3f2fb9cba3316fd68914a7a5aa4fbcbee2b3b6e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1436/agentshield_0.2.1436_linux_amd64.tar.gz"
      sha256 "cae9ebb4ab2c0dabe7461c6542380a9a0a6cb310d43a944c3f01da6e4405e77a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1436/agentshield_0.2.1436_linux_arm64.tar.gz"
      sha256 "156391c5b7758fe2e80f77405377f4b7a22f29c29e46e39de1784baa2dbb37b4"
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
