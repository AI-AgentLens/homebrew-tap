cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.944"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.944/agentshield_0.2.944_darwin_amd64.tar.gz"
      sha256 "bbf43f33ca94842f900f8a485711741cb1fa9bce840506852f7b9e7bc34e6183"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.944/agentshield_0.2.944_darwin_arm64.tar.gz"
      sha256 "05cacb172b7596df0366a937375c3b7e003d0a906cc33d17e47e8ea66b74016e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.944/agentshield_0.2.944_linux_amd64.tar.gz"
      sha256 "f55ea0f5ff397e8f182133f6ff0fdf6e6ffa138bff3df7f10f68266b505bcdd6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.944/agentshield_0.2.944_linux_arm64.tar.gz"
      sha256 "75a7ec3b84e362d18c90ba1b5b163d6255080f10d5b62d7bde82d565e9e498db"
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
