cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1122"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1122/agentshield_0.2.1122_darwin_amd64.tar.gz"
      sha256 "1d38b3694955d9d23fcd4c79de282ec99fb339dde461d04c259ed4e110a0d52e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1122/agentshield_0.2.1122_darwin_arm64.tar.gz"
      sha256 "2c72580333b041e7af1b46e3a60d840eab13ae719b73038853c460cc6bcf3290"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1122/agentshield_0.2.1122_linux_amd64.tar.gz"
      sha256 "382c8cdd78db4f65e7696131c5cf957ebe1bdfdb8ef6f91891fe9446af959706"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1122/agentshield_0.2.1122_linux_arm64.tar.gz"
      sha256 "2082f45496d9b41bc88db22ce6eee6b458746bcde76e975461dd10f2d51a6cf9"
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
