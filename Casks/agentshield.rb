cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.576"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.576/agentshield_0.2.576_darwin_amd64.tar.gz"
      sha256 "8206915a7c44e8541e512633f4a0cd5aaf9a9f1ed0e26135c7e236fd2a92969e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.576/agentshield_0.2.576_darwin_arm64.tar.gz"
      sha256 "0ad17fded8d5e97f85d35c7b6fc64c38da46b15a97d6599f7c4c450f63b07533"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.576/agentshield_0.2.576_linux_amd64.tar.gz"
      sha256 "2a92098e5eb1a0ce858f3577adac862a162fa6324189cf5166b91e17a47670ce"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.576/agentshield_0.2.576_linux_arm64.tar.gz"
      sha256 "054049bd191a67f1237f44cc0a2da0ac442a902a7a2fe281dcf280feedbd770d"
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
