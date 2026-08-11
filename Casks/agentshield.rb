cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1816"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1816/agentshield_0.2.1816_darwin_amd64.tar.gz"
      sha256 "4cdb559099dcec234f4256d0e020af3f71d02a21f2e4a6b163f00df7c183ad15"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1816/agentshield_0.2.1816_darwin_arm64.tar.gz"
      sha256 "6ff3fad2d1faea2609c31aa47ad364088b80991345c0e5e72f9a702c004c2e47"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1816/agentshield_0.2.1816_linux_amd64.tar.gz"
      sha256 "fc2f66f4a3e79f4b9f0b6a97651cb34306b12bdd0975f7ffa745393ae0d9169c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1816/agentshield_0.2.1816_linux_arm64.tar.gz"
      sha256 "f3f762ab72eb683e9f9f1861be056719ab2784694682ec75f4590bd360bf03b3"
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
