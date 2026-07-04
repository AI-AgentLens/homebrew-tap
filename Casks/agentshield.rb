cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1553"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1553/agentshield_0.2.1553_darwin_amd64.tar.gz"
      sha256 "3dbfdc74f1134d328c78ea3a19108afebd684a008c8439c91d3f8ede8f9c8230"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1553/agentshield_0.2.1553_darwin_arm64.tar.gz"
      sha256 "c9c081dec5f5e1dad603740d7121b5d770227fdf4ba020b57c4d2b12eb661d9a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1553/agentshield_0.2.1553_linux_amd64.tar.gz"
      sha256 "202cc71e0640814e2ead2a3ae4f808705460950a002a536141b205a8e7aaf370"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1553/agentshield_0.2.1553_linux_arm64.tar.gz"
      sha256 "864d5c4db85b49be327c8d7fe942b13068a25c8f54d9b1504cfd8c89b7a3934b"
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
