cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2041"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2041/agentshield_0.2.2041_darwin_amd64.tar.gz"
      sha256 "e671f8139a369965bbc2919e4f234ea4cb508f0073433b096cdd5d32daea2b40"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2041/agentshield_0.2.2041_darwin_arm64.tar.gz"
      sha256 "47d80d2c335d86d6b596b4e162354b4dc9ee1b5301f2744b667a062d6eb22666"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2041/agentshield_0.2.2041_linux_amd64.tar.gz"
      sha256 "160afe38554044ce73ac3c9b2554b06035b74e07f7665f3e42ebf1801ec1e8d0"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2041/agentshield_0.2.2041_linux_arm64.tar.gz"
      sha256 "ea9e32d050e716eb060e87239416ee2bf30c9cb130f8897fbee280e3edcaef96"
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
