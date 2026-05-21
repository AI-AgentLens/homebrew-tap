cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1058"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1058/agentshield_0.2.1058_darwin_amd64.tar.gz"
      sha256 "e90ba7708dc8eb2515a858a928b44306fff8643742fae3f50c6a48097adf86bd"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1058/agentshield_0.2.1058_darwin_arm64.tar.gz"
      sha256 "f24c057f035718b49e78edb7423beb449bd07674878239f4b2f3aecba7b12581"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1058/agentshield_0.2.1058_linux_amd64.tar.gz"
      sha256 "7d41137ad8ca9ff16769de5be2bd0934bf7c0aa8a8c85e1a63217604deb64a87"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1058/agentshield_0.2.1058_linux_arm64.tar.gz"
      sha256 "862b13488c41503b080ca4239541eda4a37944920322348267bbcfa06dbba905"
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
