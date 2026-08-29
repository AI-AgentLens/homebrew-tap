cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1980"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1980/agentshield_0.2.1980_darwin_amd64.tar.gz"
      sha256 "bfab99d363a3b1a07f497bcfaae346369cec074c43a46b0ed8fedf702d54ba6b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1980/agentshield_0.2.1980_darwin_arm64.tar.gz"
      sha256 "a69d11814cc34ec7e94f99cd8d1a9d8cf77bbd36fbf3a33c896e752c76886ce2"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1980/agentshield_0.2.1980_linux_amd64.tar.gz"
      sha256 "163f6936df1438940e4064305856c087aac7dfeed69b8c04aaafab2ff8256963"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1980/agentshield_0.2.1980_linux_arm64.tar.gz"
      sha256 "6d810e3356dd157c84d435fc77f0f96d2da13577386f7fe07994b86429d83824"
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
