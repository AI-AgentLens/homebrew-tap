cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.295"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.295/agentshield_0.2.295_darwin_amd64.tar.gz"
      sha256 "307569e2e2189d9b5508c31fa872cc78f570bc1af8f3b6f2fff1455fdf5883b4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.295/agentshield_0.2.295_darwin_arm64.tar.gz"
      sha256 "df3319a01565aa43944cfb8db2e985c8a60a9b0eba28c7d94485cb8e3908838f"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.295/agentshield_0.2.295_linux_amd64.tar.gz"
      sha256 "c90699dfb8c9a6860bb279cea9c3832584b0d1afcb5584d5c67db8b88f7b2e5a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.295/agentshield_0.2.295_linux_arm64.tar.gz"
      sha256 "b26ac47b43bf5ccab3d52c588106f2b6ae02be7a9b096f1e3f1c4df76e562a25"
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
