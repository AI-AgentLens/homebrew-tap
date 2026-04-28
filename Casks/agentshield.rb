cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.798"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.798/agentshield_0.2.798_darwin_amd64.tar.gz"
      sha256 "d14d1a43168dc7f2e7f18c605928fc38f3cae1683b4ba2f11edb4c6cb6bc93f0"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.798/agentshield_0.2.798_darwin_arm64.tar.gz"
      sha256 "8a687b0f7bca78b25a7ee8d043c380ab3e62f2f924aa3eaaa927e3bc1fba6859"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.798/agentshield_0.2.798_linux_amd64.tar.gz"
      sha256 "41e9a5d47bbb0bfca843f55a1f069c53b56e55ae2c383b177b1f6819e35a0a8b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.798/agentshield_0.2.798_linux_arm64.tar.gz"
      sha256 "ca222d50b530415f3a361eea5521f6ad0d060db9752c2f0676c68563fc109084"
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
