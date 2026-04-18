cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.636"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.636/agentshield_0.2.636_darwin_amd64.tar.gz"
      sha256 "e7e60ac72e8c5dd751ed265b9e70a8f8bc0329d60e5dc64d4545b4db182c4f0e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.636/agentshield_0.2.636_darwin_arm64.tar.gz"
      sha256 "3522237768d54a9970aec61747e7d5b122b357203209771ab7c1e6b39523b58a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.636/agentshield_0.2.636_linux_amd64.tar.gz"
      sha256 "5708e94d52ff3dd1e2488a9d67e8cb0aa0ac18e14f51fc25e27bbe58123c0520"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.636/agentshield_0.2.636_linux_arm64.tar.gz"
      sha256 "801dd2d065b8997ff44f1f5a73f0b23b2967ae97a51bcc017a0515e27ef3db97"
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
