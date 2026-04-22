cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.684"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.684/agentshield_0.2.684_darwin_amd64.tar.gz"
      sha256 "f31854a5b5785bd0c7f074420e7c957a97ff53a9e4c5bd5fa3b0a7bfb52351a1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.684/agentshield_0.2.684_darwin_arm64.tar.gz"
      sha256 "02bcad542ef6c7b906bc4a72be6c577c8a10bf65649e90b0f3563f3a40b7c1b9"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.684/agentshield_0.2.684_linux_amd64.tar.gz"
      sha256 "81fc29d5dbd74b5d80dc6e3685c19235832799f85463e0e0b80e771005a9e502"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.684/agentshield_0.2.684_linux_arm64.tar.gz"
      sha256 "d6bc66727871d451ce9a3870a088d676e1e35b39c1f05598a980b1f20a876786"
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
