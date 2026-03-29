cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.196"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.196/agentshield_0.2.196_darwin_amd64.tar.gz"
      sha256 "e70a54d77b4d9a11890eb7490de69dc1eff46c5c875b91de719abe08d31c119c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.196/agentshield_0.2.196_darwin_arm64.tar.gz"
      sha256 "5c077c7649faa0d08fdce9a13be2796bbdb44eb74b49f4240c22b488a74ae5bf"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.196/agentshield_0.2.196_linux_amd64.tar.gz"
      sha256 "e265a7a565cd7bd48668b89e17697b688f76234b989bce61f50439e6b72ebf3f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.196/agentshield_0.2.196_linux_arm64.tar.gz"
      sha256 "0eed21c7afdd787baeabc6792e24ddbe5a4884029412c39a965d000916e5e466"
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
