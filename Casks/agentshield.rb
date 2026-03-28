cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.162"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.162/agentshield_0.2.162_darwin_amd64.tar.gz"
      sha256 "06adb498ec8c80dfe319c3e48d2c54932acb4541706c9d78f0a413c81efee2b4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.162/agentshield_0.2.162_darwin_arm64.tar.gz"
      sha256 "c803b54ecdd143de6983e72d1598f440ac11a1e1c1c8ebf560bcdb78040fa2c5"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.162/agentshield_0.2.162_linux_amd64.tar.gz"
      sha256 "accd53b89d5a7c3ba536d17616f4fb3fda301778c91b499f05855342294a2d72"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.162/agentshield_0.2.162_linux_arm64.tar.gz"
      sha256 "89dd85ba669ac35aaa44fe5e2f9b9471f0dddc3669dde4b80ae8195f344a85dd"
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
