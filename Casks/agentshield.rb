cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.685"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.685/agentshield_0.2.685_darwin_amd64.tar.gz"
      sha256 "49f8c77d7845decfe74ccdc9ff70803679a569d647ce4feea24b4b05239aa0a4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.685/agentshield_0.2.685_darwin_arm64.tar.gz"
      sha256 "198c4c1616a4ebeb4061c4015db411110d3670af95712be662bfa5241726c90f"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.685/agentshield_0.2.685_linux_amd64.tar.gz"
      sha256 "ed803fae1afceae5e6fe2a7f2b516a02df7f2e2ea180092fdc593600a1d922a2"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.685/agentshield_0.2.685_linux_arm64.tar.gz"
      sha256 "4dd26db73c7a5570503f459817f1301a4be2ed72095f7a0c6d692562d892d1a6"
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
