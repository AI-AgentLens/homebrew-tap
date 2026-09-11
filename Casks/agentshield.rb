cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2121"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2121/agentshield_0.2.2121_darwin_amd64.tar.gz"
      sha256 "71d4dc42707e0991c924b29406173266d85a5b8d3b2d982d9f7e5d672bd84fdf"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2121/agentshield_0.2.2121_darwin_arm64.tar.gz"
      sha256 "bea067631a0c05e49c97410778e839f9baa59f49d4c79165ac2f3bd319a52206"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2121/agentshield_0.2.2121_linux_amd64.tar.gz"
      sha256 "264fb190bb9e2fe1383bf8ec9f6e3d1a4e63c8fce5ac7839469263d2744780a2"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2121/agentshield_0.2.2121_linux_arm64.tar.gz"
      sha256 "fa3a03e92ded56d32133a1b8a5ca25a8a36b25005c7fa0809404da9d2c16db10"
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
