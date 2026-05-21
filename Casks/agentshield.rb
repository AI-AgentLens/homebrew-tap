cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1052"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1052/agentshield_0.2.1052_darwin_amd64.tar.gz"
      sha256 "ec79222f085301bd9129af17094785a6d54a85a50dc9772109d4dbd971cef30f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1052/agentshield_0.2.1052_darwin_arm64.tar.gz"
      sha256 "652b53904128732546e3ba8bc93fca7fe9f569ea6fbe2b5713f3e1b9cbfebeb6"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1052/agentshield_0.2.1052_linux_amd64.tar.gz"
      sha256 "5e94ca86bbf58c2115b895120d3db702d5951e4fbf3f7e8d2644c749cd385e48"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1052/agentshield_0.2.1052_linux_arm64.tar.gz"
      sha256 "a34622f4d0f8a7d9c73c9695d84ee529c3cf18e0a4b7c0996c143ede9ebc53fd"
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
