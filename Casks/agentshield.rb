cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.752"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.752/agentshield_0.2.752_darwin_amd64.tar.gz"
      sha256 "07eabc6ebab50a9f4d58e6c87b6c72183f1362e15e2fbd9ed46636f25eedd32a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.752/agentshield_0.2.752_darwin_arm64.tar.gz"
      sha256 "edf56ef8a7f449d891528127629a68331ef4f03e3d0518f08536ede5d12c759c"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.752/agentshield_0.2.752_linux_amd64.tar.gz"
      sha256 "487fbd8a45fb5300b8ba47518c44b4e9114eb96b5962271ce3ea49cfc4b7fcaa"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.752/agentshield_0.2.752_linux_arm64.tar.gz"
      sha256 "62d2b6d834c83b8fe11fdeebfaf690e51b974ed82964a36ae7ce4216a70e1802"
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
