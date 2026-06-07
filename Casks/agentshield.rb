cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1235"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1235/agentshield_0.2.1235_darwin_amd64.tar.gz"
      sha256 "c46565b1f68ec5af9f3ba3fe58378b08723ae32201034fa6190791a800905b74"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1235/agentshield_0.2.1235_darwin_arm64.tar.gz"
      sha256 "c664c629225fe4820bc96573215a7982b2fb60882a2c0c6167a6fd92f779149a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1235/agentshield_0.2.1235_linux_amd64.tar.gz"
      sha256 "fc74e92fdcf8b008b1f43f613fb67de78254aeb0e7944f933ff80820a64b1534"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1235/agentshield_0.2.1235_linux_arm64.tar.gz"
      sha256 "f07f71d8a883760a1b57900b5c5d8a3e75751ff684fbe2ad9d1e4814a4facac4"
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
