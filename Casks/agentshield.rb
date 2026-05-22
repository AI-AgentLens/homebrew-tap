cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1072"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1072/agentshield_0.2.1072_darwin_amd64.tar.gz"
      sha256 "70535d25a140931832192f9798b01810303627a0a2494fbe4c6a4a1809cb60e9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1072/agentshield_0.2.1072_darwin_arm64.tar.gz"
      sha256 "6b3ad889473839e2a77e631bc9ce0619797c229a8dc6c2dee1add4e496ca3fa3"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1072/agentshield_0.2.1072_linux_amd64.tar.gz"
      sha256 "20a450c7f343f6bd6bc3c54da1f66f674eae9f85ff66ddd980a05209c10ff6a4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1072/agentshield_0.2.1072_linux_arm64.tar.gz"
      sha256 "3a2783df317f4fc3e2e1a8e2b1a1bd25d4e2b49edf72c5f856f98f9fbe3d1225"
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
