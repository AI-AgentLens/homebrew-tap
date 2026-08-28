cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1971"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1971/agentshield_0.2.1971_darwin_amd64.tar.gz"
      sha256 "262e83bc1577a4e5ae8f2de30785aa1fb7014fa8aac3c287794fbe88db8e5231"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1971/agentshield_0.2.1971_darwin_arm64.tar.gz"
      sha256 "02f446d0ad2ec4555dc625f770d3cd6d1450124b649b5107fe5e53c7e10ab008"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1971/agentshield_0.2.1971_linux_amd64.tar.gz"
      sha256 "4c615ea3792b24720b20d644474d2a4bc510c8651d4f1638a5cf0ce2431639ec"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1971/agentshield_0.2.1971_linux_arm64.tar.gz"
      sha256 "f99788d2a49f1b75bb55594efec52c998ef8b87069bbbb33288df772ccc5bcad"
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
