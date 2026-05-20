cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1047"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1047/agentshield_0.2.1047_darwin_amd64.tar.gz"
      sha256 "aae9b5f89846ce5bd0fbe718675632a162b2c4c0b55fa13664b8459aa722c4d3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1047/agentshield_0.2.1047_darwin_arm64.tar.gz"
      sha256 "d39ec32e21054106c9280bf16f81c5b3514f0a88b3ec9f6e90c7eb3bc4598482"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1047/agentshield_0.2.1047_linux_amd64.tar.gz"
      sha256 "a9c9b950dd83061c5c4c2d881bca689050a87dc4fad62eda2a02021088354215"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1047/agentshield_0.2.1047_linux_arm64.tar.gz"
      sha256 "80be61a8907526e4b1bc5f8952efbafbc10d1cdc3ab7e09dcf7d99cec22b2384"
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
