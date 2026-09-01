cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2014"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2014/agentshield_0.2.2014_darwin_amd64.tar.gz"
      sha256 "1d6ce891fba2b10aca073c6f8a1a852695e44687334f94123c49d909eba8487d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2014/agentshield_0.2.2014_darwin_arm64.tar.gz"
      sha256 "ab05afb84bcd9c755745947129a6aac3a9dd2e0c63dea8206460bfc6843c98cd"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2014/agentshield_0.2.2014_linux_amd64.tar.gz"
      sha256 "8bc0067d1691c54d3ab40304a15d720f07ce89632b671f9de2ca54fbe1fb5137"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2014/agentshield_0.2.2014_linux_arm64.tar.gz"
      sha256 "ec0fa34fd07598cb2b6e58ab79f74ec1cf33b6db7f29cf68cfde11f8d7e116d5"
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
