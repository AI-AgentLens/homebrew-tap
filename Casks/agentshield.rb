cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2313"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2313/agentshield_0.2.2313_darwin_amd64.tar.gz"
      sha256 "e7e991699e2d36115df0bfcaf8c190aba5f127be8a3e1d6708d9367636f1662a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2313/agentshield_0.2.2313_darwin_arm64.tar.gz"
      sha256 "7e38398813383966308fa58642d4ecc9c2cc2a0acf749a51411737b7cd6d89a2"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2313/agentshield_0.2.2313_linux_amd64.tar.gz"
      sha256 "10eeab3c5d2374bc174027b73486cb7f5dae28ebfa8a837564bd6c4d9890abd4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2313/agentshield_0.2.2313_linux_arm64.tar.gz"
      sha256 "37b6b48c3d674590b094bb624e0c7c0ea05e4bc32ff1823708f11ddee5a15e6e"
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
