cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1201"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1201/agentshield_0.2.1201_darwin_amd64.tar.gz"
      sha256 "0a73bb2ce092ef4ccbf87c3e84a374fa922d56a7afc9c8b89bb9758dec092776"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1201/agentshield_0.2.1201_darwin_arm64.tar.gz"
      sha256 "e5c9fe3b8e331d034047589706cd822dbb08e8cddc83ee7cd6c1d46c9ab216df"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1201/agentshield_0.2.1201_linux_amd64.tar.gz"
      sha256 "1ffc735d116c84079fc6f82fcd66e3303cc97b8fd302b992598a00c8cf3ee27d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1201/agentshield_0.2.1201_linux_arm64.tar.gz"
      sha256 "5e691f9aedbba24234929cb8e210d0ffae0f45a3b379ad8de6bf7a751f78e324"
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
