cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1049"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1049/agentshield_0.2.1049_darwin_amd64.tar.gz"
      sha256 "0b01e8f1299de941558dd7674043bfd4f6edab5c22cc1fba02e01e69999ac484"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1049/agentshield_0.2.1049_darwin_arm64.tar.gz"
      sha256 "85e21e420cd851ca8546e77e0257485cbd4c52f7e31ef15476c14d79f68257c3"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1049/agentshield_0.2.1049_linux_amd64.tar.gz"
      sha256 "b6a5f0ff180a2d873f5921508d23f2b960df7a001cf44da907ef59c4b876fc1b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1049/agentshield_0.2.1049_linux_arm64.tar.gz"
      sha256 "c2b093a5121ea38603868dd13e7a3cca5caf4ed7c26b8e4ea646d24ac1912b1a"
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
