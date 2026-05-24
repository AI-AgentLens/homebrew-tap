cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1107"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1107/agentshield_0.2.1107_darwin_amd64.tar.gz"
      sha256 "8960caa7e4d93dc1013814e5a20d1f62bbccfdced54a68ed2a0caeb87a53e171"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1107/agentshield_0.2.1107_darwin_arm64.tar.gz"
      sha256 "33de90d2f3d5ec0832ca8ba602f63abe28e2c5d82a4f8b599f1d5ac3f2db0750"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1107/agentshield_0.2.1107_linux_amd64.tar.gz"
      sha256 "287fa55d0b27100797b9837184a552642d00de9bf6a55b6d3336f566a1424c60"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1107/agentshield_0.2.1107_linux_arm64.tar.gz"
      sha256 "ac20cac6caa22eabdbb894c8060ea1a1767e6002a9221d4127998bd3de9ab027"
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
