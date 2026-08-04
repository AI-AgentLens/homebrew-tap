cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1782"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1782/agentshield_0.2.1782_darwin_amd64.tar.gz"
      sha256 "1305ecfd8cc2bdce25c8c558c136f6b247b96331581274879e45b4ba3325c340"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1782/agentshield_0.2.1782_darwin_arm64.tar.gz"
      sha256 "fa8db0a05e5acc27453b0e754d11cbb68fa4abd8d00b29a0119b0c63b2ce11b7"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1782/agentshield_0.2.1782_linux_amd64.tar.gz"
      sha256 "c66ab473e4c9fc150ff308ac08d2e50a7c1a31290fe8600d2a8f53d2345ceece"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1782/agentshield_0.2.1782_linux_arm64.tar.gz"
      sha256 "b4c424e6c109ac9dec365397032655291c4b3efd3b6ad01d8dda138fc2870701"
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
