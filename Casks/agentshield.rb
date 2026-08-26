cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1960"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1960/agentshield_0.2.1960_darwin_amd64.tar.gz"
      sha256 "3e0df3c7c509b73f83f4d2a044b77f068084451ba8f9bf83edd5fedb0d954289"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1960/agentshield_0.2.1960_darwin_arm64.tar.gz"
      sha256 "393b63468aba105f76437b36ca635ff7db0adbddd48de2705b0c87a8e8c2a118"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1960/agentshield_0.2.1960_linux_amd64.tar.gz"
      sha256 "07e746038c7c4544af404c5de237f6643be095a8a74ceb704195feebebd9d6ed"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1960/agentshield_0.2.1960_linux_arm64.tar.gz"
      sha256 "8c4d354b58902ff82b81e30b32ae96744b9af3907822f4ca54e5334ddb27814f"
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
