cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2069"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2069/agentshield_0.2.2069_darwin_amd64.tar.gz"
      sha256 "82d5c67b7f0e8bc9da4d608d8a03272c10e9800f9c8b6305cac4b6b04c7b6c77"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2069/agentshield_0.2.2069_darwin_arm64.tar.gz"
      sha256 "57814eb84eb8f8edc1d4e04ca568bc46c590edab0010ac434a5ad40dcd542e2a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2069/agentshield_0.2.2069_linux_amd64.tar.gz"
      sha256 "229e75bfd119b22771fb1e45289d05d491961192d0deb50193a9da0e8a72908e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2069/agentshield_0.2.2069_linux_arm64.tar.gz"
      sha256 "088cd3763ee5723cda146d23cf880295ed6385bfe2a1ae1674c4a17d12673354"
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
