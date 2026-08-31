cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2011"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2011/agentshield_0.2.2011_darwin_amd64.tar.gz"
      sha256 "6638d2e5dd2838b770f110be1c6ced61edf6c803d0b00a9c4f82bd72d5dd223c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2011/agentshield_0.2.2011_darwin_arm64.tar.gz"
      sha256 "6b56ad119f2af16baf59f1985f4ce49bd80c1df6e7701d96da383593ca69d222"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2011/agentshield_0.2.2011_linux_amd64.tar.gz"
      sha256 "44ea8fc8eb18ff4e6c17b99c2687ded309e3d68a08f293734546ede4fa45ce8c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2011/agentshield_0.2.2011_linux_arm64.tar.gz"
      sha256 "744b7437edacee2b743d1fdcbb4ff48db824e5f985ac763974e2c00afa54416a"
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
