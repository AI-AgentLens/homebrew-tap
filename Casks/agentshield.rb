cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2435"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2435/agentshield_0.2.2435_darwin_amd64.tar.gz"
      sha256 "63188ed8a9fd7816e26cbef82908b84b1781d50d0c24d645396e3c471b209bd3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2435/agentshield_0.2.2435_darwin_arm64.tar.gz"
      sha256 "12f11cdfc5e89871343774431714676fd90b206ef282b0d76b1f88a08bd2b142"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2435/agentshield_0.2.2435_linux_amd64.tar.gz"
      sha256 "224f994fbcfaea995a776854ba4350a63efaa042a60ebdc11b4db5aefd050fd1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2435/agentshield_0.2.2435_linux_arm64.tar.gz"
      sha256 "b352d909dc8505071e7ba4053b2a2bb1d63fdeceb0c394922ee9589228a49b33"
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
