cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.670"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.670/agentshield_0.2.670_darwin_amd64.tar.gz"
      sha256 "14a4ed22cd224ae997eb58ca6ff1d8597f494d077dafd898e8b4fdeff493fcf1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.670/agentshield_0.2.670_darwin_arm64.tar.gz"
      sha256 "b0f6744427eebd1d7d907503b287df7dd7d82c32e91da5864f33c44bb2da4cd9"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.670/agentshield_0.2.670_linux_amd64.tar.gz"
      sha256 "e2f2dffaaea0076a4ce1c321ee99613e1e10cc5b58f478f971f4fe55cadf04e1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.670/agentshield_0.2.670_linux_arm64.tar.gz"
      sha256 "afeb40fbbc290cdeefbd664a33d2c4e188d4ff542c4cd60f41b897b69abc0dcb"
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
