cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1866"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1866/agentshield_0.2.1866_darwin_amd64.tar.gz"
      sha256 "aa7a841863b71d5cdabb2847dd60f3253e1d55390f26877bd8218808befb98b0"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1866/agentshield_0.2.1866_darwin_arm64.tar.gz"
      sha256 "7a29baa1355bc62f2b313191685987495e8402528e4e290d1b9c19b01dc9b2e9"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1866/agentshield_0.2.1866_linux_amd64.tar.gz"
      sha256 "211031bcf8288ddec138eeeb75b761d4e9d36efffdba4937fcd87f3285101a1a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1866/agentshield_0.2.1866_linux_arm64.tar.gz"
      sha256 "04437385c89b3382ca0b6820fa8f1658da14ddb8681e04e17de5c9c8dd732db5"
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
