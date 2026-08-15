cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1868"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1868/agentshield_0.2.1868_darwin_amd64.tar.gz"
      sha256 "a85b90f14069cded155e32baf1fa21d036459749621dac7fd0def465d5efb312"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1868/agentshield_0.2.1868_darwin_arm64.tar.gz"
      sha256 "323602d96c04e51cd28558e9a308037ef6d720ee8102624c3be49fa9daea92e2"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1868/agentshield_0.2.1868_linux_amd64.tar.gz"
      sha256 "7cd375a367189ed3453ec7d9bac179f3652f7ff1ba2d8e055b7192b93c748a0a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1868/agentshield_0.2.1868_linux_arm64.tar.gz"
      sha256 "d8f172afb73edc02a671a7c73f21728b749254c75c61d92e6caef34ab3023d37"
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
