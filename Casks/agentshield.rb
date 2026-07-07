cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1580"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1580/agentshield_0.2.1580_darwin_amd64.tar.gz"
      sha256 "288ef0208e58f56e27de362752744b9f43820db0695c82ef8aab976a0c21096d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1580/agentshield_0.2.1580_darwin_arm64.tar.gz"
      sha256 "2657b0c0930ec0978bb06cae7b51b5e2f7f2a0712a9cb049024bc7a02d91a4d7"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1580/agentshield_0.2.1580_linux_amd64.tar.gz"
      sha256 "da9160e4e129f635885528fcaeb7b5932d60c3f7fdc09c3f8957d7e438570f4d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1580/agentshield_0.2.1580_linux_arm64.tar.gz"
      sha256 "efabf6d6463a2d0ebcf089740f7746d9110991199afe56c13dfbc486c89ba28c"
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
