cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1995"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1995/agentshield_0.2.1995_darwin_amd64.tar.gz"
      sha256 "d5b02bf8b2bd75d32e6056c943fe1a1bf63b3f5e57ab660a264c6a8c0d0bb9d8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1995/agentshield_0.2.1995_darwin_arm64.tar.gz"
      sha256 "9636eb4faa630a1ecc13d2f031c784188159bef6ce6714e4f86aaceba04cf8f4"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1995/agentshield_0.2.1995_linux_amd64.tar.gz"
      sha256 "6c6ff8cf630b27ec9a3e1524214afd32911e23988fe3ed54383cff2fe71e553b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1995/agentshield_0.2.1995_linux_arm64.tar.gz"
      sha256 "1fd0ed30e9007c8f7a0563d97110991bd984bb5a49c018f1c8d1627563ad04da"
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
