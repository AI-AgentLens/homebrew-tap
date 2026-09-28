cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2279"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2279/agentshield_0.2.2279_darwin_amd64.tar.gz"
      sha256 "36dd71da0e2dc16ff1fd85d36c34593bb30ec0583efaf483979687f5fac4a119"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2279/agentshield_0.2.2279_darwin_arm64.tar.gz"
      sha256 "64f841d1799b32cb0b58a4e40f8e7ce1297513d615b43962e1c9a43f0b88a70e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2279/agentshield_0.2.2279_linux_amd64.tar.gz"
      sha256 "60dc4cc8adcb4dba99508d38427a1418d254266b27cff504ff2044aebce0cbbc"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2279/agentshield_0.2.2279_linux_arm64.tar.gz"
      sha256 "67c26493e4d861a7c510ab436fdba496a8f8fe5773b4112ccb2ac991da74d037"
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
