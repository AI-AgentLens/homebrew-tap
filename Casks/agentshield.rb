cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1586"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1586/agentshield_0.2.1586_darwin_amd64.tar.gz"
      sha256 "83fda46f8f849cecb4f789c4498c2be352b22feb2c4166e7735a51c06a8efbd2"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1586/agentshield_0.2.1586_darwin_arm64.tar.gz"
      sha256 "0729fd45b59543f262f3ec36af33753ef19f7989f2c0d41158a6c0e068379020"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1586/agentshield_0.2.1586_linux_amd64.tar.gz"
      sha256 "ecf4534a1978089e4d40430d73593652e31f498e34a16df643ad122d136c1398"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1586/agentshield_0.2.1586_linux_arm64.tar.gz"
      sha256 "cbda4ec288faf1c789d6f8883c581c6a1a1da8a3c27a56cd313e5a61cdd9322a"
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
