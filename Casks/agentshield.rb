cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2275"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2275/agentshield_0.2.2275_darwin_amd64.tar.gz"
      sha256 "a31f9a57ffbe4fd66d9430297fd9f9d46c1b4910cc453e1214a228eaf6dfa905"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2275/agentshield_0.2.2275_darwin_arm64.tar.gz"
      sha256 "6d1bbfc8d0ca4acce341ca101485c138b446c3d9163b67e3a906a55766e9cffe"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2275/agentshield_0.2.2275_linux_amd64.tar.gz"
      sha256 "8c5511773011b024f7ae2c0a92bc4d322b1eed61c5a548ec20947bf9ab12529c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2275/agentshield_0.2.2275_linux_arm64.tar.gz"
      sha256 "38f8fb715f45f45b7f7ebe7becb4fa0649e712f52b9323f6f73939598cea0fab"
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
