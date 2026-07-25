cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1725"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1725/agentshield_0.2.1725_darwin_amd64.tar.gz"
      sha256 "dadc5d1823098c692dd055981ef2e3c72eb902ee4c4b4db480758b531867033b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1725/agentshield_0.2.1725_darwin_arm64.tar.gz"
      sha256 "61250fc9ed5e6780d6b5404c15e38731e91864c486359cb1a9655b616bdb6abf"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1725/agentshield_0.2.1725_linux_amd64.tar.gz"
      sha256 "f41cdc9a9afc308a7227200401e9815a75bc469fea3f4d4fdfd93e8f861898a8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1725/agentshield_0.2.1725_linux_arm64.tar.gz"
      sha256 "2f48021a08b6ed934a431b55da591d3635e53fd45f78feb17397d0b0394d79df"
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
