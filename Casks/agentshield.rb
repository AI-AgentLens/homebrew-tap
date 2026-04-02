cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.332"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.332/agentshield_0.2.332_darwin_amd64.tar.gz"
      sha256 "7f094fc5356b597cd08d81d5771350531c61425f75164558f6e9cde428efcc65"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.332/agentshield_0.2.332_darwin_arm64.tar.gz"
      sha256 "bf9de968bc884ba96487f07ec513945d11213ac0ae9ee614834bfcaa2aff0748"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.332/agentshield_0.2.332_linux_amd64.tar.gz"
      sha256 "3e57f08950344b47bc2f9be904db335bc66abfb9693916200973355835b3ebfc"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.332/agentshield_0.2.332_linux_arm64.tar.gz"
      sha256 "f3e04838c2896d31fdba8e32ae4b813468a3604b5172b4fad2da5b3f2d5096d6"
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
