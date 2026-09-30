cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2289"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2289/agentshield_0.2.2289_darwin_amd64.tar.gz"
      sha256 "140084d46302f6afc621a007f7a4a1bc0f13fc71e18d236a4420d12d2b4b72da"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2289/agentshield_0.2.2289_darwin_arm64.tar.gz"
      sha256 "bfef65f746a6e65f40c221fb6df11919a1590543ca11acfa1260869feed97339"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2289/agentshield_0.2.2289_linux_amd64.tar.gz"
      sha256 "a1e394ec4f266938c6141d0c567eadd81e78937e0ca90bf4431a8536e3d03af0"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2289/agentshield_0.2.2289_linux_arm64.tar.gz"
      sha256 "802acbe7f43cd1184709b8be0b381c4ef3ce978169657ab01349ff050f6fe8cc"
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
