cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.932"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.932/agentshield_0.2.932_darwin_amd64.tar.gz"
      sha256 "d42de16cd0d33d1b606c6d039e7bdca73ffb332f08aba74612b0ed2031984ca1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.932/agentshield_0.2.932_darwin_arm64.tar.gz"
      sha256 "354721de19e60cf3f37e9ef72b5766725f6add68ba708b040356f163d16505e5"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.932/agentshield_0.2.932_linux_amd64.tar.gz"
      sha256 "cfd626e92eb7805c6a601fd8be51a677c023a3d322ea8b89133cda64144d2edc"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.932/agentshield_0.2.932_linux_arm64.tar.gz"
      sha256 "059591331dc12a70563c6bfcbffd2e7be07b418e32fb26e82d3a95958431a725"
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
