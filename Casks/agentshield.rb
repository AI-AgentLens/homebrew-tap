cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1144"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1144/agentshield_0.2.1144_darwin_amd64.tar.gz"
      sha256 "de6baced1eeef94b0b41a373d91537da9ae05b62e2032fcdb065a90a2a73dd7e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1144/agentshield_0.2.1144_darwin_arm64.tar.gz"
      sha256 "aa54f6ea990f6a24c63246e77d12bb722496b93c1abec0de3753752fc0bbce5f"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1144/agentshield_0.2.1144_linux_amd64.tar.gz"
      sha256 "cd9afb94d2b4378cec7e0222f474a113e2b7f956d648e593772443d291a04a59"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1144/agentshield_0.2.1144_linux_arm64.tar.gz"
      sha256 "40cf223aae8a54beff6e060ceceb858812d2d9acce34ad1211b5a71e0055d883"
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
