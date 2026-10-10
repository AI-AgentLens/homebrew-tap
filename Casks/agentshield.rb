cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2390"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2390/agentshield_0.2.2390_darwin_amd64.tar.gz"
      sha256 "0426dfbe2aaf2f1af5257b0a2d1a85441c92105f4145aaf467759a24d8df1399"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2390/agentshield_0.2.2390_darwin_arm64.tar.gz"
      sha256 "5d9063b604d03430aadfe5f195d56062daa60ae914404a52d81632b9506c1d88"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2390/agentshield_0.2.2390_linux_amd64.tar.gz"
      sha256 "b8e852d8caeefe5787cd16c9e705553f0a12ebbf3e4dea112d596597010981c3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2390/agentshield_0.2.2390_linux_arm64.tar.gz"
      sha256 "0eb429450920e13db94429aba4ffa8f3ff67d96a3d4a587b928d4aca5d0c3461"
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
