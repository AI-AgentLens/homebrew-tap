cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2036"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2036/agentshield_0.2.2036_darwin_amd64.tar.gz"
      sha256 "6df6bc67f4ced575198f9a05b42a1508e3ca3517cc988cdd57e38c8d851f0e3c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2036/agentshield_0.2.2036_darwin_arm64.tar.gz"
      sha256 "bd9b993a0bf7ba356a3d0e663ce6d40c1b4a33858a113617db8e0c0e0a9cb40f"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2036/agentshield_0.2.2036_linux_amd64.tar.gz"
      sha256 "e45bb22a8c2885b581ee41f52e7a9023874980928fad52da20ed88cf43844ba5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2036/agentshield_0.2.2036_linux_arm64.tar.gz"
      sha256 "63647bdef1b2f07fb8789e697a60d5caaf02fc1f756371ca01794894055953fb"
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
