cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1609"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1609/agentshield_0.2.1609_darwin_amd64.tar.gz"
      sha256 "6fb2f9427f728192da9efdd39962028fb72afac281bc0f675a9d3cbec67bca75"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1609/agentshield_0.2.1609_darwin_arm64.tar.gz"
      sha256 "a0d3366052b2a1f97dcf9a9162223e941f008a4936607b1c0bbca89ee58e7f20"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1609/agentshield_0.2.1609_linux_amd64.tar.gz"
      sha256 "3c0fdda0afc78c260c9cd26b2a811d0a4613b3ccd76fa352ab9108b7e35fbe1e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1609/agentshield_0.2.1609_linux_arm64.tar.gz"
      sha256 "b55297048dacf506c3fb9a1b3ed74c3d4437cd0a5a0ead7c0e9d722bba5d7e12"
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
