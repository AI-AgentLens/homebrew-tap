cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1193"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1193/agentshield_0.2.1193_darwin_amd64.tar.gz"
      sha256 "080728f987fbb6581c2119637f7193dc2f82bc364520e6b305f4f2484edcfaaa"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1193/agentshield_0.2.1193_darwin_arm64.tar.gz"
      sha256 "c13d2eaa01e6d72c81ccff917696d6f92a6318428cc6029eec75c9835fe8b9d2"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1193/agentshield_0.2.1193_linux_amd64.tar.gz"
      sha256 "fb324fb897368af3c53201d9629e2e36aa5ef7a39e912630e0c2d78e003497bf"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1193/agentshield_0.2.1193_linux_arm64.tar.gz"
      sha256 "cdcecb8491c67228c3ebdbac44976ca29e882f3e403fb669faff68f527b15177"
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
