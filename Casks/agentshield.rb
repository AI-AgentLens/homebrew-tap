cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.971"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.971/agentshield_0.2.971_darwin_amd64.tar.gz"
      sha256 "af535efa17aa3bc840682f957ceaaf90262d9ec882c0393e2eb50037fddcc563"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.971/agentshield_0.2.971_darwin_arm64.tar.gz"
      sha256 "29c0d0f25b45d93ee222ee25588023fe20c6adff0eed02990a5e35554d01816f"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.971/agentshield_0.2.971_linux_amd64.tar.gz"
      sha256 "4002d34b40b0485e788ec47c8276d4e65c492b5d3f7adcae0b3e147e1d82d85d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.971/agentshield_0.2.971_linux_arm64.tar.gz"
      sha256 "72aa6ca0df3d59c86c798acaa269ccd0a92540ddedb579374d0ce8683667d6c9"
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
