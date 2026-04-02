cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.291"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.291/agentshield_0.2.291_darwin_amd64.tar.gz"
      sha256 "d2b8b0888a9fb31591f9f175c3a22ef8a4c5644933ba5c7dc0c398aa7bc5b21b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.291/agentshield_0.2.291_darwin_arm64.tar.gz"
      sha256 "b7d3e669d66b7b3102114e0aa846b5348fc188907b7b3466cb945c923d9c7e0f"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.291/agentshield_0.2.291_linux_amd64.tar.gz"
      sha256 "ca8122988b296d124461fedfc282881f655f09c924f993823e99e1054c714158"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.291/agentshield_0.2.291_linux_arm64.tar.gz"
      sha256 "23e9cbf5ab69e365b24bf49ad2b776cbee6184b07cdcfeaea38c8d4ccf39b442"
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
