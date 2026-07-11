cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1618"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1618/agentshield_0.2.1618_darwin_amd64.tar.gz"
      sha256 "192eda2f3f0e3f54986c248c73983ec5c74c3c2aba623ceef43702c0f0657bbd"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1618/agentshield_0.2.1618_darwin_arm64.tar.gz"
      sha256 "1c3fd80eba0ac80a6664f2e37890467e45ad59159d718886c5603072fb8e02d3"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1618/agentshield_0.2.1618_linux_amd64.tar.gz"
      sha256 "516a94f915ebdb9b533f4708a00b08a0368e8604699b9f709678fd1e3dface88"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1618/agentshield_0.2.1618_linux_arm64.tar.gz"
      sha256 "4c0851390c857a2bfd5e22dff94587c8d50593b88bb08c2b9868868645447980"
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
