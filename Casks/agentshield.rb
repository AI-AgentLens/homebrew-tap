cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.548"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.548/agentshield_0.2.548_darwin_amd64.tar.gz"
      sha256 "cf5bd2b9003a067e9e75e853d4c78df70ee266fe8812cce7238bdfeaee113904"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.548/agentshield_0.2.548_darwin_arm64.tar.gz"
      sha256 "e50623f634f66913e394dd967383e26934804a8c3783352390a9dbd58c65749c"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.548/agentshield_0.2.548_linux_amd64.tar.gz"
      sha256 "a1d0773e50ff5631aca19ef5c1fe60b45e83b8fbed40c74389c7bbc502684fe9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.548/agentshield_0.2.548_linux_arm64.tar.gz"
      sha256 "e0253309821c3cd355df11f2088ef1bb0fd9eba66cbb290ce8591ba4104f3a38"
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
