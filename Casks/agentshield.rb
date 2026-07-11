cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1616"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1616/agentshield_0.2.1616_darwin_amd64.tar.gz"
      sha256 "21db26b139d238209c05622ea339b2b8b67bc6344fc9aaaaba0c95ac4c6b6f6f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1616/agentshield_0.2.1616_darwin_arm64.tar.gz"
      sha256 "1c04eb1e7f3689c90bd8efb1dd7e06ff96409d100329ee7804a6acbc46904cd3"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1616/agentshield_0.2.1616_linux_amd64.tar.gz"
      sha256 "191149e5ef646e734dd7fcd8a14642f15d1f2b145bec8eaec8351bd61210f91f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1616/agentshield_0.2.1616_linux_arm64.tar.gz"
      sha256 "06165d85d06d4438a93024d12eecea012be9488d4599183d9511ab8ff3c453bd"
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
