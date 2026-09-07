cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2080"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2080/agentshield_0.2.2080_darwin_amd64.tar.gz"
      sha256 "769d4d75546aa08040911b7a66c9b5c774f3b0c8c6a19212d49103ab57a39f45"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2080/agentshield_0.2.2080_darwin_arm64.tar.gz"
      sha256 "6e058da2ac3ff53d8b7131e71ecd34256a869a95b721d320ec9ea8fe1d562b3c"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2080/agentshield_0.2.2080_linux_amd64.tar.gz"
      sha256 "672252b208c938593f56ee63f00caabc39b7b422c66e123a9b861f63305387b3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2080/agentshield_0.2.2080_linux_arm64.tar.gz"
      sha256 "3e263da874b4ba2a6a912daf309032c45c91ad66c785a244f621b318242c9843"
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
