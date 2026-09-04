cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2039"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2039/agentshield_0.2.2039_darwin_amd64.tar.gz"
      sha256 "f92462c37b4dac28843b22bdc46be47bcca61570a829da47612158ce119ce101"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2039/agentshield_0.2.2039_darwin_arm64.tar.gz"
      sha256 "372ae2b0caea71ffaec0010efcb700c341173fb38c7a319c195b9ecf7f6365e5"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2039/agentshield_0.2.2039_linux_amd64.tar.gz"
      sha256 "991d8ef809884e407ed534d55fbc776568eaa7afa860464b45a4cd86923e8978"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2039/agentshield_0.2.2039_linux_arm64.tar.gz"
      sha256 "1440e2254eb2395d9823f6435cf35540fafca323d35f780edae14599ba17df76"
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
