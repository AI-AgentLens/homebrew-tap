cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1169"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1169/agentshield_0.2.1169_darwin_amd64.tar.gz"
      sha256 "0a11fefd082636522297960cbc0514063eeb3c931783ddd488f27a05fe033ced"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1169/agentshield_0.2.1169_darwin_arm64.tar.gz"
      sha256 "f7f8c308b37c75ba7415a605a5e5a9ebf3a46f9f2ec2873a859a81aec6486120"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1169/agentshield_0.2.1169_linux_amd64.tar.gz"
      sha256 "090686966ec81db4c50c738c122e922dbd4bf4a94fa1e9b19cfa2651d924f922"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1169/agentshield_0.2.1169_linux_arm64.tar.gz"
      sha256 "afffb91158ad2ecef283e11ac11da2dbff2a87b3c392ad2113304934fea1ae85"
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
