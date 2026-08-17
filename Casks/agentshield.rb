cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1888"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1888/agentshield_0.2.1888_darwin_amd64.tar.gz"
      sha256 "677994d12046f86c7f6ccf804b6247998d77da77ad6aeef0ee5d31a62c42f4f5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1888/agentshield_0.2.1888_darwin_arm64.tar.gz"
      sha256 "271536a4940d81fc776b030d6ff9d7bf10e56835e4f5728159d05866ef5b504b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1888/agentshield_0.2.1888_linux_amd64.tar.gz"
      sha256 "bd4657f521912f645e9870615b26bf2008b3c9c6794386afdbdcf7a3695bdef7"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1888/agentshield_0.2.1888_linux_arm64.tar.gz"
      sha256 "c248c321579c4d1f704881fda41bba595c7c4a1b40794ce8ea927a45cc587b3e"
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
