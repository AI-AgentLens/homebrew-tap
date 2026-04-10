cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.532"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.532/agentshield_0.2.532_darwin_amd64.tar.gz"
      sha256 "189bef195daf3b1676f32e2959b7367333792e91e52e539d6e6513ea65c1523d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.532/agentshield_0.2.532_darwin_arm64.tar.gz"
      sha256 "9c28cd26e61797f774c3cacaf0a9e5f6d441da8fef0b9cfd22789bbcb57e8094"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.532/agentshield_0.2.532_linux_amd64.tar.gz"
      sha256 "0b98ba665656e3faec298d3dde93e75bed387635f37363532721036dca0bb69e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.532/agentshield_0.2.532_linux_arm64.tar.gz"
      sha256 "65334564a8e6a650037a7578c09574121d3f7006e8b8a06812f57de6c56c3c3a"
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
