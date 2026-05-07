cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.894"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.894/agentshield_0.2.894_darwin_amd64.tar.gz"
      sha256 "25203f415de28441aa7d741c427b5bd024d0653ab92e2b35522dc96ab6236c6a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.894/agentshield_0.2.894_darwin_arm64.tar.gz"
      sha256 "6880dcdc4531c75165e284e6137d0c3939ee474c54ed51d477c8e4c9ff66e03b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.894/agentshield_0.2.894_linux_amd64.tar.gz"
      sha256 "295829477335ab3bba497e674e730800ea2e1b3aa95ea09ae5d67deb08ac36e4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.894/agentshield_0.2.894_linux_arm64.tar.gz"
      sha256 "9e1a2beb182eff1fb9f496dbc8c061184ee7c082588dc5fbd53389f23cd670e3"
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
