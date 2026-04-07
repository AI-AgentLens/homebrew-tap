cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.441"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.441/agentshield_0.2.441_darwin_amd64.tar.gz"
      sha256 "ce9a525e2a4479540a81fe0bd0d29efa5deed52da3e6ef8ee29825a092d17d4b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.441/agentshield_0.2.441_darwin_arm64.tar.gz"
      sha256 "a22f421aa15b66ff1089eebab7e979cafd56d23d9fab7f590f9f2fed9925216f"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.441/agentshield_0.2.441_linux_amd64.tar.gz"
      sha256 "93ab888d66f77f9cffa2ee987b641e7ec1f657dc4321d5f72ed958ca50ca3efc"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.441/agentshield_0.2.441_linux_arm64.tar.gz"
      sha256 "9034d9648a33aa9523205c0d7561e991c641119e61d1c48a6185599e7b7d755a"
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
