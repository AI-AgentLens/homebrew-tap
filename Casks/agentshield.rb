cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1219"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1219/agentshield_0.2.1219_darwin_amd64.tar.gz"
      sha256 "f5a1201487178c6a2a164b92fc6d965520e94c18b35a46e0baf8450654310b0c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1219/agentshield_0.2.1219_darwin_arm64.tar.gz"
      sha256 "d8842f1833677e44a5813df0767c0bffe495b7e38e57e8f6924bd913092cdc5b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1219/agentshield_0.2.1219_linux_amd64.tar.gz"
      sha256 "04cda524af7b885128e4378caa0873908f03a94342184f8d3dde72da645077da"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1219/agentshield_0.2.1219_linux_arm64.tar.gz"
      sha256 "5388fc27817f6a96fb203196030bd94c412d62b166629b7f2681177aa19f39de"
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
