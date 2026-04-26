cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.742"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.742/agentshield_0.2.742_darwin_amd64.tar.gz"
      sha256 "cae6baacf7df835f5821b1f4e248d6bca2d55dd9c41285f35a1bec138ea1a799"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.742/agentshield_0.2.742_darwin_arm64.tar.gz"
      sha256 "90a0f8063fc3c348bd42df5f2ae01ef37ceb3e35df6215b1e65e413826c5c5cc"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.742/agentshield_0.2.742_linux_amd64.tar.gz"
      sha256 "16d5377bd8392076eaa0198e6f544778d71bc29a19608175d175569c5b65c972"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.742/agentshield_0.2.742_linux_arm64.tar.gz"
      sha256 "e5af008feb83751aeeb4afbfa35354bfd4a32c91ad2f03d35ac49cb368376398"
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
