cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1382"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1382/agentshield_0.2.1382_darwin_amd64.tar.gz"
      sha256 "b32d79d3c7930b235f4cbac970cc4cabd02cfe664aa8a08c5bfcc96cedb7e730"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1382/agentshield_0.2.1382_darwin_arm64.tar.gz"
      sha256 "217fe196759c31f38ab53a20c040003abd0b980944ea569205e727c7b03d0665"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1382/agentshield_0.2.1382_linux_amd64.tar.gz"
      sha256 "3d2d159be79e14eaaeeb9e6233fc61f6cedb32d33870bdffa5881abde0000695"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1382/agentshield_0.2.1382_linux_arm64.tar.gz"
      sha256 "053651cdd6c3d6afcda8f0e420676fab3ddb931074a357bae435bdbf9a1a2fad"
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
