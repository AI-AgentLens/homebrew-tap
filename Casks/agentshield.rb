cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1621"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1621/agentshield_0.2.1621_darwin_amd64.tar.gz"
      sha256 "4be1a3fb63165a628c6b83f5b43d79469eb438ca6efa9ea170a02b8b88f9e932"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1621/agentshield_0.2.1621_darwin_arm64.tar.gz"
      sha256 "e718489a58dd5f31de80f985340fb26640bb19650a522c89f91fb10c8c25ea97"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1621/agentshield_0.2.1621_linux_amd64.tar.gz"
      sha256 "777256574b6e91b77f9277c86a37c445175b9cb1e9fe8d06b9c03c3ca0c69149"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1621/agentshield_0.2.1621_linux_arm64.tar.gz"
      sha256 "05dcca4a0ac2c2d347415f66fef3df64d47f81f6529ba08fa0222dd64b647cb5"
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
