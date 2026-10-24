cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2521"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2521/agentshield_0.2.2521_darwin_amd64.tar.gz"
      sha256 "db0c4f53bd5a1cc7848465cd2ed5f6c94ec4ce588201d915bcdcb1c3bf35048e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2521/agentshield_0.2.2521_darwin_arm64.tar.gz"
      sha256 "df75608ca21148cb275994e7f808974579f75233f95cf26c0bdf53bf829c1f12"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2521/agentshield_0.2.2521_linux_amd64.tar.gz"
      sha256 "9e31930f3897a52c1949616573ed00634ab304ff1ecc41646416b693592854ee"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2521/agentshield_0.2.2521_linux_arm64.tar.gz"
      sha256 "8b06c9f370bd28e43618caaabfc2c10457b3c5db98151758a2b366fb76cc6b54"
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
