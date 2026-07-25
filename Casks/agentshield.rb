cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1726"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1726/agentshield_0.2.1726_darwin_amd64.tar.gz"
      sha256 "04ff182384ba108b5a033c46ea23f806c25ecb92a85ceef0e33085a68b3ac2f5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1726/agentshield_0.2.1726_darwin_arm64.tar.gz"
      sha256 "8b215b37f282693695cd1c218d22580913544511384c90495dfbd631a33abba6"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1726/agentshield_0.2.1726_linux_amd64.tar.gz"
      sha256 "f30b0ac98968d94c8f3ce4ce57a867af7d1354012b3f8f02480187139b2f94e0"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1726/agentshield_0.2.1726_linux_arm64.tar.gz"
      sha256 "f0b0944c898678c6755c4e7e9e28bf605c2c28c99e833218d4e17cd1747d97ec"
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
