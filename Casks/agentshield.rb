cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1911"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1911/agentshield_0.2.1911_darwin_amd64.tar.gz"
      sha256 "0110a691a889f6e52b7ac9937341ffbc5de38e03924361292fbf108a91ba20ab"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1911/agentshield_0.2.1911_darwin_arm64.tar.gz"
      sha256 "fe25d4ebe5366ff5f2580080343492bbcaa940ac1b3664374c0edfceba2f2473"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1911/agentshield_0.2.1911_linux_amd64.tar.gz"
      sha256 "03f466c9a298a6c6282c637902740ec6701c7d8129e311ac4090ed0c643b76d7"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1911/agentshield_0.2.1911_linux_arm64.tar.gz"
      sha256 "a1b28635c4a85cd0698825b6b2c7cd5d35315c7ad9b828a501b06b4f2e895922"
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
