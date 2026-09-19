cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2186"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2186/agentshield_0.2.2186_darwin_amd64.tar.gz"
      sha256 "8dc82fde89c14608b05fcde8a3c291f739548e3b44d7832f9529f01db12ef288"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2186/agentshield_0.2.2186_darwin_arm64.tar.gz"
      sha256 "cb8394335c0a7e930e872f1657d98ffb7b4410664517604f515cf5b8b2c8654c"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2186/agentshield_0.2.2186_linux_amd64.tar.gz"
      sha256 "1a308d6601df2f23c3f9cdb9bb1351517fd759148dcae3fe777bf36fd777c873"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2186/agentshield_0.2.2186_linux_arm64.tar.gz"
      sha256 "cd0254b18c618e326fcdf6c1096ffa9695c97deb10f9c059b7d1569fc52d9789"
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
