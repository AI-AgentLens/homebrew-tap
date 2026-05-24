cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1110"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1110/agentshield_0.2.1110_darwin_amd64.tar.gz"
      sha256 "0fb209241d91a6c57df77df2f958b85343f1b18f76c8ba7b77aaa5a947a98df6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1110/agentshield_0.2.1110_darwin_arm64.tar.gz"
      sha256 "6dd108ad2f267d2d72bf39d7a6a2c130319c61896eb04deefef8047183c8984d"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1110/agentshield_0.2.1110_linux_amd64.tar.gz"
      sha256 "85f9cb69a17cba97e70ef80050bec37235fa98dba3190028131b97920dcb3f7a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1110/agentshield_0.2.1110_linux_arm64.tar.gz"
      sha256 "8aee8d4fd20d9f55c8f00c57fd429590b45845e3e228f40bbf5d9ce186447e17"
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
