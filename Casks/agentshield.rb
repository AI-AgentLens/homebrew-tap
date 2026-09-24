cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2243"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2243/agentshield_0.2.2243_darwin_amd64.tar.gz"
      sha256 "cbf9d73f9ba95c700c26b5d0f66d71033c8b7ccfb4ac87b938017481f73149c5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2243/agentshield_0.2.2243_darwin_arm64.tar.gz"
      sha256 "b615b58d5f0252758632354ce96cf564a824ac660c9d970aec0455d219e86bfb"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2243/agentshield_0.2.2243_linux_amd64.tar.gz"
      sha256 "c326450f754bcad1d2478ac0d8187a167cba30f1615d8fcda355a37f31f83bcd"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2243/agentshield_0.2.2243_linux_arm64.tar.gz"
      sha256 "6023d6bcb5ff74ffa416720365227e7a4c21fac35fa3a72a2b374bb8db6f9632"
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
