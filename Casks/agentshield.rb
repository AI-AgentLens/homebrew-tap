cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2166"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2166/agentshield_0.2.2166_darwin_amd64.tar.gz"
      sha256 "01412a831be511742e4fce70dcfc3f1d38d5cd58bc5d199c55620b48b6c75af6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2166/agentshield_0.2.2166_darwin_arm64.tar.gz"
      sha256 "822d7faa80d184758d8f16c3c4f7f0f08f45e8991b58906e925c8d1ba45ee960"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2166/agentshield_0.2.2166_linux_amd64.tar.gz"
      sha256 "116df584c102f5c3bb961ba1f1e98d91c77a32bb52b510ded0d55151b7d697e1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2166/agentshield_0.2.2166_linux_arm64.tar.gz"
      sha256 "cf3b9e2b2db503426523c3ff43402205c2bd06fd97386c9d4997d6de14bd1f8e"
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
