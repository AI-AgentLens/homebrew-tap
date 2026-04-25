cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.726"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.726/agentshield_0.2.726_darwin_amd64.tar.gz"
      sha256 "f0661b75277592d90f583f1fa2c53d2203b20f33902776612f0acf6e4f69d71c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.726/agentshield_0.2.726_darwin_arm64.tar.gz"
      sha256 "265b6df5ae7436919bba791e7673cc54205b0a9b845c6f702d0cb35f4fd7436a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.726/agentshield_0.2.726_linux_amd64.tar.gz"
      sha256 "43c4b63d6b184c2d673c3231842c1a026aa920f230ed7f5cb98f70bc559a287f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.726/agentshield_0.2.726_linux_arm64.tar.gz"
      sha256 "2cc3059ad943435cb3d66f974ecb332e46edf5eb079fb063b4a4e6001e0291a7"
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
