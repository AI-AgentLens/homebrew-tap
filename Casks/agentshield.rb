cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1141"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1141/agentshield_0.2.1141_darwin_amd64.tar.gz"
      sha256 "8c99098f0f1ac24665568d2a1ec49bebe609fca2be873a3f57567e1ea30be46a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1141/agentshield_0.2.1141_darwin_arm64.tar.gz"
      sha256 "1c8f8098ea8abda0091bcaf2ce892a07aaa508ff6690e565c3b4e05c7238afde"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1141/agentshield_0.2.1141_linux_amd64.tar.gz"
      sha256 "b3a2aa3e4a19a371431cf77088792d9829667490930892005ec57663f48307d1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1141/agentshield_0.2.1141_linux_arm64.tar.gz"
      sha256 "bbf9ede491d8f79960ad2fc9b4e3ab4e62c2bb337efbfd185a49b6429e36b925"
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
