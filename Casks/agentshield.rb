cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.148"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.148/agentshield_0.2.148_darwin_amd64.tar.gz"
      sha256 "4267ff694f8def9a041b6acbff5a33bd8e23abffc04aced0f227cef63615481a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.148/agentshield_0.2.148_darwin_arm64.tar.gz"
      sha256 "6660444c2181863e9eebabd93f00465927b176c4358f2905adb7d82728b99161"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.148/agentshield_0.2.148_linux_amd64.tar.gz"
      sha256 "ccedf4c17e8bb5ad2e601f6fadbc5f8948e482e175a88fa2e437660859e3180d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.148/agentshield_0.2.148_linux_arm64.tar.gz"
      sha256 "35c17ebeaf1ac5a3fef709d8c434d09c66c0371e34d47c995ddd82377a89594d"
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
