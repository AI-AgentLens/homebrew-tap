cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2086"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2086/agentshield_0.2.2086_darwin_amd64.tar.gz"
      sha256 "9b20099bf1f70e6af26f369b30c1d42e069734ccc79775cc92d5acec313b097d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2086/agentshield_0.2.2086_darwin_arm64.tar.gz"
      sha256 "58e6982b8f3412c66d30e72c42c57e41cd1954c62372200b9d4fa52abd13d0d7"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2086/agentshield_0.2.2086_linux_amd64.tar.gz"
      sha256 "5f8ac9189f00d44a8c9c4444ac952e6e8ebb7bb7adaf6bc9e9e04219f38bd04c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2086/agentshield_0.2.2086_linux_arm64.tar.gz"
      sha256 "2e36edb004fffd4c88f3554553f511aedda0c76b6280ca89e2c331dcfbd9dbe3"
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
