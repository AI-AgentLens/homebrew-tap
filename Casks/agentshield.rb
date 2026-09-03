cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2030"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2030/agentshield_0.2.2030_darwin_amd64.tar.gz"
      sha256 "22722361b25b3da08298a3bafa6127ab2853b0086e38e78a1603f962422d2ceb"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2030/agentshield_0.2.2030_darwin_arm64.tar.gz"
      sha256 "22c56c3185f540c91d615aae9ec1a37415e7de7898d46e24606513e0949cedff"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2030/agentshield_0.2.2030_linux_amd64.tar.gz"
      sha256 "b3af16cba1c80b579de04749b8ac51d54c21f1c848478f91e39c391ff7d0f571"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2030/agentshield_0.2.2030_linux_arm64.tar.gz"
      sha256 "918411b185089329ceb6d2c9ecb99883ba6f6a872b5ffee5dc2f8819be60af3d"
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
