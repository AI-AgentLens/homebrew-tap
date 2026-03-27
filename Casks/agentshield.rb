cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.113"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.113/agentshield_0.2.113_darwin_amd64.tar.gz"
      sha256 "24294f8158c9e5f1183821cb82507335cf6ec4f3a5311efbb7b7760e2272f5fd"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.113/agentshield_0.2.113_darwin_arm64.tar.gz"
      sha256 "b50fd9454a601616e86adf9bf54b3ece4e31447b117ff84e4072c286ce535ab1"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.113/agentshield_0.2.113_linux_amd64.tar.gz"
      sha256 "4a951ae04a54cdde5cc889eb2dcf750e8ed6a5879b81e4ffa159dd10b8cc0939"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.113/agentshield_0.2.113_linux_arm64.tar.gz"
      sha256 "ec59ab427ad1667109beda758b08da9349c770cb5b094170e0bda044f2fb7a34"
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
