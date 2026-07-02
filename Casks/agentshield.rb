cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1527"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1527/agentshield_0.2.1527_darwin_amd64.tar.gz"
      sha256 "d4bee2991220072435117c6eba729d854a3c4870f5953868e4fde456bdcffe31"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1527/agentshield_0.2.1527_darwin_arm64.tar.gz"
      sha256 "e60664fe033f242e5dc35982d01fe5900ee66ed7952e0b03259e9a12391342de"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1527/agentshield_0.2.1527_linux_amd64.tar.gz"
      sha256 "bd5f4dbceaf015ae712f42a7c39714e68555c5d72b3cafee4e979dc5e02b3839"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1527/agentshield_0.2.1527_linux_arm64.tar.gz"
      sha256 "2ed7c0071658ae200d09535035bc06bc47a810643611c590bc9c07811763f6a3"
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
