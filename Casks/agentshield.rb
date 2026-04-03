cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.364"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.364/agentshield_0.2.364_darwin_amd64.tar.gz"
      sha256 "86dfc8ae8790f6dffcdbfd7609d785b794a792022ccb2a9feb5ab6dec2623d6b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.364/agentshield_0.2.364_darwin_arm64.tar.gz"
      sha256 "713bed42c40cfcca3e58c5d0757bea0eee332afd8e5e0781aff53cd4341d2b8f"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.364/agentshield_0.2.364_linux_amd64.tar.gz"
      sha256 "337570cd65827e9ddd9ec8569c31b71db84faaafee74ca80e2672fe58dffaf8c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.364/agentshield_0.2.364_linux_arm64.tar.gz"
      sha256 "4616b2b72f63937cf883c228b234ae5b7eeb3239c5fe68e2dc724e4c6470de80"
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
