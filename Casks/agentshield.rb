cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1530"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1530/agentshield_0.2.1530_darwin_amd64.tar.gz"
      sha256 "316dc3e54b3e8e9cd20e619d38b1e357c17629a29c4f4b5e47506ef89fdcaebb"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1530/agentshield_0.2.1530_darwin_arm64.tar.gz"
      sha256 "43882a3a440461c2ba721a954e021748ed1c92c6f4f5902ef91949da5f877325"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1530/agentshield_0.2.1530_linux_amd64.tar.gz"
      sha256 "008e9f43a35b4079753958dc777278f78f20d7b68794b872352a191c09661a41"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1530/agentshield_0.2.1530_linux_arm64.tar.gz"
      sha256 "3c5b9fd40c95dcff46f278942fc026b9ab4e12e43a22b356f0dcbb3e1f717363"
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
