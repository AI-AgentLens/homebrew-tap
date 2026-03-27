cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.85"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.85/agentshield_0.2.85_darwin_amd64.tar.gz"
      sha256 "3181b5dc717a4fa254c2658c1ce968314b55fe086819a2070ea350ff36a5fe16"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.85/agentshield_0.2.85_darwin_arm64.tar.gz"
      sha256 "670cb706b2ae90a7278b8a85580b366257a5b38f73afab3a131aad7d4288027e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.85/agentshield_0.2.85_linux_amd64.tar.gz"
      sha256 "81f3ea3233927f284df90ac4381e260c6f4a055b2369efe64301a42570a1eb67"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.85/agentshield_0.2.85_linux_arm64.tar.gz"
      sha256 "b521ec77d288749190a417d3a80e4a97bf4377265404e6bafcd05be4957e6f2e"
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
