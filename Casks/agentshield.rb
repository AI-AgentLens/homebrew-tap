cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1587"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1587/agentshield_0.2.1587_darwin_amd64.tar.gz"
      sha256 "1e900295460a7fa45d7edf26fcb8e9ad984929340fac0a5bffb7bb6a8766e985"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1587/agentshield_0.2.1587_darwin_arm64.tar.gz"
      sha256 "cfde3390aa719fca98fd806c7b1e7802fdac9921c357169ba05fbeac6cc75782"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1587/agentshield_0.2.1587_linux_amd64.tar.gz"
      sha256 "a1e00b9a80510b0491fd5c2c4476cac063f6fe0ad48ad51d98d25d837c6192c6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1587/agentshield_0.2.1587_linux_arm64.tar.gz"
      sha256 "e6f01dd1e777d0234214fd6f404a30f421363fd7362a2551a2740d14d75d55aa"
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
