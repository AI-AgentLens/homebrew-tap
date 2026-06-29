cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1492"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1492/agentshield_0.2.1492_darwin_amd64.tar.gz"
      sha256 "46d4bedc68bc6e0b4a3ef4b99fc8fb597dffe72dc26020981a795d7ed7a9410d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1492/agentshield_0.2.1492_darwin_arm64.tar.gz"
      sha256 "6756ab66f0f1d4eca77e50d2de997614ff33312067a9ad16b9fc128460c9c5f6"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1492/agentshield_0.2.1492_linux_amd64.tar.gz"
      sha256 "ff8308f750697fd1c39563e23192cffa7b89e5cfbeedd79ed8ad85bb132b56f4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1492/agentshield_0.2.1492_linux_arm64.tar.gz"
      sha256 "e1f039ca9642e5b813fbd2338c9dc91618e30ef12b2fa5da79d96e6777a73633"
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
