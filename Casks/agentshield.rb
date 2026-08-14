cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1851"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1851/agentshield_0.2.1851_darwin_amd64.tar.gz"
      sha256 "48f08b8d8636a5142616fbdf4bd3e45ab3c7dad7185ce4f3686bb3cc30a52224"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1851/agentshield_0.2.1851_darwin_arm64.tar.gz"
      sha256 "b22d99bb962e882db06851104cb4bb758ead562d10f737f739a197a5c28aee9f"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1851/agentshield_0.2.1851_linux_amd64.tar.gz"
      sha256 "09ea8d01437f4d7b8650a17c47081be6570f43148b608f064a9db51a7e1ba819"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1851/agentshield_0.2.1851_linux_arm64.tar.gz"
      sha256 "30dab1879f5e3cc0cc8180a682ba92536028a71f0667a5e40cb2bf2af07582e1"
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
