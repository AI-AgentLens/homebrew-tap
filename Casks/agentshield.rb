cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1561"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1561/agentshield_0.2.1561_darwin_amd64.tar.gz"
      sha256 "2027484d4bd6cdef0a86556720a5eeb8d2b0ba97149694df1ca4b30e8a27152c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1561/agentshield_0.2.1561_darwin_arm64.tar.gz"
      sha256 "cac54d06efde4961cc68a897b245a241def376d916c8e14841ba1b36c63cdb08"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1561/agentshield_0.2.1561_linux_amd64.tar.gz"
      sha256 "2a95059619b7fcb93175828421897a58e9aa0765f12e94897b7a80c828d57434"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1561/agentshield_0.2.1561_linux_arm64.tar.gz"
      sha256 "1f6f1397c7bd434ed01fc82954b6afda77f95c5fad19b79e9b0281b4a95641fb"
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
