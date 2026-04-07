cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.479"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.479/agentshield_0.2.479_darwin_amd64.tar.gz"
      sha256 "bd02d59680a00fbb171d2904c01e1faf5f1075dec207ef1717adb833f7f808fd"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.479/agentshield_0.2.479_darwin_arm64.tar.gz"
      sha256 "8513a06fc42bd0fd61690a013de3237584e67c95bffaf76cd1a8c0b3d47cd3af"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.479/agentshield_0.2.479_linux_amd64.tar.gz"
      sha256 "82cca3db425bbc4f9a2e59611044db62625b7c2eb7ecedd2e3e96f6611e51456"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.479/agentshield_0.2.479_linux_arm64.tar.gz"
      sha256 "ca8784d705dc4dc430062e5f1767864d0d5a1fa24b45a89c5e501eae25e64b40"
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
