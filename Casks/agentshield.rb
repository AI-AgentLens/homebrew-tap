cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.813"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.813/agentshield_0.2.813_darwin_amd64.tar.gz"
      sha256 "d54850ed9bcf40ab57835f78abfa65211617a7c0d1d7b799ce34538b5b06dfc7"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.813/agentshield_0.2.813_darwin_arm64.tar.gz"
      sha256 "bb89e55520a3fb095f6134c3a07e63afd623548411b7c06ad676f2c15b4756d6"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.813/agentshield_0.2.813_linux_amd64.tar.gz"
      sha256 "47d1373642e6474059276e7fd7593c9333be323c4e6653b09e0bbfb7a255e2e6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.813/agentshield_0.2.813_linux_arm64.tar.gz"
      sha256 "f33e03983025bd690f4bcd4b28a2e3a6901444db76e41e1c65baf0c322899a00"
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
