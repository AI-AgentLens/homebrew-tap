cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1731"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1731/agentshield_0.2.1731_darwin_amd64.tar.gz"
      sha256 "90e4595c77d6a4c9b8e9d941e3cc1ada6b70f5067ffe8d436ad81c526e47a4bf"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1731/agentshield_0.2.1731_darwin_arm64.tar.gz"
      sha256 "81b0cd86bb86ede78e5385b1a8fc1f52b06399518ea48e3b06707d7bce6af1b5"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1731/agentshield_0.2.1731_linux_amd64.tar.gz"
      sha256 "69405db5dce8756c96f5bb140208bb4677b1bde9cbf98a3049506b4ffceb2d25"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1731/agentshield_0.2.1731_linux_arm64.tar.gz"
      sha256 "85124330ba0791a4a1b100644b8f79c59894545e6cc7574bc7084c4d76d76ac4"
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
