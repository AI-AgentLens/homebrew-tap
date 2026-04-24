cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.710"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.710/agentshield_0.2.710_darwin_amd64.tar.gz"
      sha256 "49383142046ac4c7dc2ff0abd4997a11b38ff4df454e8dfd31d9c0d8f5c332bd"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.710/agentshield_0.2.710_darwin_arm64.tar.gz"
      sha256 "cf0ad0954090fd4da93a129fb925e232af0b818e2c7c656a19b9ed874e7e4a35"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.710/agentshield_0.2.710_linux_amd64.tar.gz"
      sha256 "7e9195dcbcff129ceead0c005c53633c8599ce4e2db796743040875ec12a1350"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.710/agentshield_0.2.710_linux_arm64.tar.gz"
      sha256 "43639f1d23f83158741eadef92c6d76cf5ec74ca656688a25ff078580370c118"
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
