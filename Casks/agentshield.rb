cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1269"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1269/agentshield_0.2.1269_darwin_amd64.tar.gz"
      sha256 "d34fd5c49fd4bbff169cecf8c541b29e85990197f8a5eb891c03f707b41d2325"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1269/agentshield_0.2.1269_darwin_arm64.tar.gz"
      sha256 "6dcf1713d14f2f86443e0d6f632af42db299ccbf467f1cd0bb1b5c9c6535ee9e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1269/agentshield_0.2.1269_linux_amd64.tar.gz"
      sha256 "568d2fd4abe2e70edfaccb58565186394d3fec98c0bb274740325fddb49e9c2c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1269/agentshield_0.2.1269_linux_arm64.tar.gz"
      sha256 "d210e9a916690e04634bd952d1870afb5aaa6b4ec32a7f02ab494c2ac3b51e80"
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
