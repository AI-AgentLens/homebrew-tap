cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1540"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1540/agentshield_0.2.1540_darwin_amd64.tar.gz"
      sha256 "02dbd919b23edd6c3d3396a19a7c95a39e244ad0244a9c543de21098809f0a4d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1540/agentshield_0.2.1540_darwin_arm64.tar.gz"
      sha256 "eed14b61b367df28555073f89f22b0ecd165f0d95551cd0bbeac3eaf01a97e20"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1540/agentshield_0.2.1540_linux_amd64.tar.gz"
      sha256 "30b3fede2aff961707dd1f27da9c4387e54e4017ccc0157e7f5b63d81019905f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1540/agentshield_0.2.1540_linux_arm64.tar.gz"
      sha256 "868305fec67ea5561105fb102031e6eb030842b69f69afbdebc5263ebde6145b"
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
