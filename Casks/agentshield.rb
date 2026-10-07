cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2375"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2375/agentshield_0.2.2375_darwin_amd64.tar.gz"
      sha256 "f6c5db9c420ec0e29fae574f8078cb06e69e62038dfb81c016b1afad511a564b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2375/agentshield_0.2.2375_darwin_arm64.tar.gz"
      sha256 "37010c217caf11a808a3a7bc2eb8800337e03486414b9d559537d573fa223a2a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2375/agentshield_0.2.2375_linux_amd64.tar.gz"
      sha256 "c25fc12c652e3d078823f4aaf69447b8ced21f5536ef642842ea37b9a358ae95"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2375/agentshield_0.2.2375_linux_arm64.tar.gz"
      sha256 "a4cfbbcf54c8f8c37239201e9e5d00bccf38df9888cbab427292e1b781a83ac4"
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
