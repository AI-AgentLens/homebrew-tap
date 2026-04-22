cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.676"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.676/agentshield_0.2.676_darwin_amd64.tar.gz"
      sha256 "e1d191dc6f7202cddcd957f1084aa5c14f9d6bb4cd87a6c1a225342cdbb3fd19"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.676/agentshield_0.2.676_darwin_arm64.tar.gz"
      sha256 "cfd8388ced6312054cf9969051bd56090fc1057777daa97dcc00ee2d4227ef9d"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.676/agentshield_0.2.676_linux_amd64.tar.gz"
      sha256 "281c57d26496249a3ebd8e1778cee9ce627f2decb7b872b41fb14afc4e95593d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.676/agentshield_0.2.676_linux_arm64.tar.gz"
      sha256 "80abe85a6ef66f0b561f356dfc426ba5ae86dea236883c69b40f43e6ccc410b0"
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
