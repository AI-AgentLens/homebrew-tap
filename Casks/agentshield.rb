cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1264"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1264/agentshield_0.2.1264_darwin_amd64.tar.gz"
      sha256 "93f5ddfa5f501235a1c274b39140b95cba4e0eb66703c1bf292c9599faa33bbc"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1264/agentshield_0.2.1264_darwin_arm64.tar.gz"
      sha256 "9a603259e7277ed2e4e4642745711eba314ba3fef9d24cb1faf893c41908871d"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1264/agentshield_0.2.1264_linux_amd64.tar.gz"
      sha256 "7907e5cad7b4bd1bc687abe88ab11bb4f8f65afc663e8fc355e6383ea4c1539e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1264/agentshield_0.2.1264_linux_arm64.tar.gz"
      sha256 "32bd3a466197f1a531865c7cd8d81f89316d0ffa4ec48ab33c38fce136c0c636"
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
