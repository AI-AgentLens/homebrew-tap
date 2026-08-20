cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1910"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1910/agentshield_0.2.1910_darwin_amd64.tar.gz"
      sha256 "1e04a8dec6934cca7ea876ea69c7fd11793e747a089fb0f4b1cf6788d5a0765f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1910/agentshield_0.2.1910_darwin_arm64.tar.gz"
      sha256 "7f4e2ddd5be09bdcbdc78cb69e644d34216ded0adf282a59f752cbc0c880d6fa"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1910/agentshield_0.2.1910_linux_amd64.tar.gz"
      sha256 "b3de61eb9f2339490ec6ab0c2b84218f5656783b7e468cfb4ea31ec420bff1df"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1910/agentshield_0.2.1910_linux_arm64.tar.gz"
      sha256 "684b10dd09e0205e5a15d4ea8b8fdc2aa207a395304d7c88aafa665dca9e482c"
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
