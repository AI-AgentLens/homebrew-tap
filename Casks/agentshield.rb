cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1422"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1422/agentshield_0.2.1422_darwin_amd64.tar.gz"
      sha256 "eb292e293c5a033b559f50b743772a9856688e604c8ef01e90ecc228662948ac"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1422/agentshield_0.2.1422_darwin_arm64.tar.gz"
      sha256 "9aac017735ad2fade813ab7b8bcc9ff36a2403e301da2acbbfbf81083a661c62"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1422/agentshield_0.2.1422_linux_amd64.tar.gz"
      sha256 "7345b1cc8b8f2d57cd58916282bba962b13a5b4d43109f9c72a35c0c9f34e025"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1422/agentshield_0.2.1422_linux_arm64.tar.gz"
      sha256 "243edaa7b5841e2d42fd293588bb970af0024571696b0d362c4f6c37c29da4ff"
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
