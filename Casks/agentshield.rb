cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1463"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1463/agentshield_0.2.1463_darwin_amd64.tar.gz"
      sha256 "22df2334e4200e1e9ada3c0a627f63ccbe6b0cfc8706f98340b696098e1d3ab6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1463/agentshield_0.2.1463_darwin_arm64.tar.gz"
      sha256 "dfcaeb4ce879668ec5d377b005fa82aac4be06d49f27befcae3bb7922642a28d"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1463/agentshield_0.2.1463_linux_amd64.tar.gz"
      sha256 "8071319545aaa9f5a65b636c81bf07d00a8663c1f04883f24cb5b2b9f04a192a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1463/agentshield_0.2.1463_linux_arm64.tar.gz"
      sha256 "194ac2611308c8f77b0a1f44d4c4efe081dfde3c5ad682f760e35ff48e10950d"
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
