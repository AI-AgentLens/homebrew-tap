cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1754"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1754/agentshield_0.2.1754_darwin_amd64.tar.gz"
      sha256 "dd4db67ba19e884f0a7e7b66ec28963d574e975af960b11a8482f7a4c4334219"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1754/agentshield_0.2.1754_darwin_arm64.tar.gz"
      sha256 "c9a41aae2cb74ebafd31b991d58e3f2cd81442e04ca1c12bf704fdae50609f44"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1754/agentshield_0.2.1754_linux_amd64.tar.gz"
      sha256 "a45305a95e1d6843ca12c79bf89155e43ebd22db60f166cdd54a75dafdb3c73e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1754/agentshield_0.2.1754_linux_arm64.tar.gz"
      sha256 "8961b827c15087a062a5b16fe16ce5897c228591f6df05d85320b5e532a997db"
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
