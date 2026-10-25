cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2526"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2526/agentshield_0.2.2526_darwin_amd64.tar.gz"
      sha256 "fa71aac225508033790805a9d168dcd906c61c91a5ca8f11f23bbc1e26272ca8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2526/agentshield_0.2.2526_darwin_arm64.tar.gz"
      sha256 "c50f744366f33679f774f63212bc4b878f7da2843b9e48736c0655f29455259b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2526/agentshield_0.2.2526_linux_amd64.tar.gz"
      sha256 "e38448e0fb963b01906e8c5b44b8c4d68179ead890589ad264750dd0f61ec4ac"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2526/agentshield_0.2.2526_linux_arm64.tar.gz"
      sha256 "5497ba530f7abd52ba39688288a93b6036994e9280da195158b2a175b52516dd"
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
