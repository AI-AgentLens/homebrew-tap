cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.421"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.421/agentshield_0.2.421_darwin_amd64.tar.gz"
      sha256 "bc1c0acab2ffa27de09cbaf4c2a4a84f49458544edc9c6fab6043b7b86ac6f00"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.421/agentshield_0.2.421_darwin_arm64.tar.gz"
      sha256 "48dae0434632d444234f1d88710ee1045f6b815c66e70a137d6618bdc52f6a2b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.421/agentshield_0.2.421_linux_amd64.tar.gz"
      sha256 "7a68d70e96c6a3fd3ec0a2891067896ee05309f8e2eaa27e3e1c2a61dfce9fbf"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.421/agentshield_0.2.421_linux_arm64.tar.gz"
      sha256 "31314184d8fa3e62c60516dd9a5821f851992d9718acfed0277e6e8abb02bdcf"
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
