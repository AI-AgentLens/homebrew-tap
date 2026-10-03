cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2323"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2323/agentshield_0.2.2323_darwin_amd64.tar.gz"
      sha256 "f5db454352a7064f55a8ca293d54efa9af6cc19a388040e08fdf3db5203cee84"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2323/agentshield_0.2.2323_darwin_arm64.tar.gz"
      sha256 "e117e73e0691ddc609d8ae028e33701c6af3b702d095c11718d6e52fa81508de"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2323/agentshield_0.2.2323_linux_amd64.tar.gz"
      sha256 "a0aab365926c977883184b5522a86b007dcc75ae589c4b50d200b257bf914aff"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2323/agentshield_0.2.2323_linux_arm64.tar.gz"
      sha256 "9d0d14e4d96547f86aa9e2b80e0bcee2abcad6730bf0bbbb2ce1b8dbaa3d712b"
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
