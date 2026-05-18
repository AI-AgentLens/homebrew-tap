cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1018"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1018/agentshield_0.2.1018_darwin_amd64.tar.gz"
      sha256 "e8aa9876d74764baf7a6e664ca20550211d31289f216123134421faded1a6b91"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1018/agentshield_0.2.1018_darwin_arm64.tar.gz"
      sha256 "42ee46786724c66a6b7b9e83bff8266a5e5df1ec0e8f1d6e1cd8dddf007c833b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1018/agentshield_0.2.1018_linux_amd64.tar.gz"
      sha256 "3eb81df7f605077dfeac03db4d69ab24b31098afbfb3df504fb16266a8688fdd"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1018/agentshield_0.2.1018_linux_arm64.tar.gz"
      sha256 "419c9ab5a25c7b188c96a852cdcf7ef231c738db4d241fa0bea57947e76c8485"
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
