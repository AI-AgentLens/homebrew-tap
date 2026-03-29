cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.221"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.221/agentshield_0.2.221_darwin_amd64.tar.gz"
      sha256 "bbd4e8afe65b64554b0dce9a1a7f4ab51a62a67072a9b7506e991fe12a82404f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.221/agentshield_0.2.221_darwin_arm64.tar.gz"
      sha256 "10b0ca6a93f4e17933a398261f3b90509fdae5d435d5e3af9d6e7d2ed14ddcff"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.221/agentshield_0.2.221_linux_amd64.tar.gz"
      sha256 "d9ca18038b9a5ae3f0eddd49a0bffe851a3dad5e7f17633e9a6e1006317f1716"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.221/agentshield_0.2.221_linux_arm64.tar.gz"
      sha256 "5b22335c37f624e75ff2b1c338d00ebed53c84123351512647759657a9eb7072"
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
