cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1339"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1339/agentshield_0.2.1339_darwin_amd64.tar.gz"
      sha256 "5d4378117bf8c7f73f925355fc04d65d6b0cb31ad61a2a194b9698af15214ebe"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1339/agentshield_0.2.1339_darwin_arm64.tar.gz"
      sha256 "c5ab1c81f49b0436bc72e89afbe86ee5788244c36921dd412186a97d59b072df"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1339/agentshield_0.2.1339_linux_amd64.tar.gz"
      sha256 "a23257d8bf330cc08bc7a325dc8cdd5813a1455394140f6f1c901943c8214c36"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1339/agentshield_0.2.1339_linux_arm64.tar.gz"
      sha256 "963bfeb405f9140e42ad5dc84edf2fe6dfbf6862056262f71e55ec53e744c882"
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
