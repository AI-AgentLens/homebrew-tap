cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2072"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2072/agentshield_0.2.2072_darwin_amd64.tar.gz"
      sha256 "19cd98868e10a501568193b19460d8553c2219db15cb74bbea8581ea579286bd"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2072/agentshield_0.2.2072_darwin_arm64.tar.gz"
      sha256 "c0ad15449307d17ee28c7159b38cef937528787b378f02d68c5d5ab79b59037d"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2072/agentshield_0.2.2072_linux_amd64.tar.gz"
      sha256 "8ed55f70330d1c5f0d62b05b1e7d0fa623604726918e375f7583c0f6e35a92fe"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2072/agentshield_0.2.2072_linux_arm64.tar.gz"
      sha256 "d374d63b7fe5a6ef2cf7a82b4a02b7f7c5c2fd870af98fd86818ce1777fb34da"
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
