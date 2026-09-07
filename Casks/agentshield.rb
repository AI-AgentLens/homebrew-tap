cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2081"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2081/agentshield_0.2.2081_darwin_amd64.tar.gz"
      sha256 "d0f903c6110f53123b46166fe79cabf1ccee8cc10e78856bdf7e31022999e309"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2081/agentshield_0.2.2081_darwin_arm64.tar.gz"
      sha256 "bc02eff3f5931c731cc3e8e0ab26c1910c80402c908062da3d25a9bcefa06ebf"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2081/agentshield_0.2.2081_linux_amd64.tar.gz"
      sha256 "2085ee8060b2248e3501d8d01507f0f0a7ca254a1e0750d0faeda20b7546d441"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2081/agentshield_0.2.2081_linux_arm64.tar.gz"
      sha256 "aadad819000ed6ab41436635d8bab27c274c591e57589b25eefc5719cfd12a2b"
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
