cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.874"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.874/agentshield_0.2.874_darwin_amd64.tar.gz"
      sha256 "ac2a2a72fdc8172f36144d5a43d3d039d6d872ac884db514400a910561068d38"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.874/agentshield_0.2.874_darwin_arm64.tar.gz"
      sha256 "771d8b505d408588537d8126c4213c34bd8bfc3e6e58680a75524f8d4485a2a4"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.874/agentshield_0.2.874_linux_amd64.tar.gz"
      sha256 "6aeaed7f7d97943ad0849f24aeba3cf1885a31c2526a4a21b0d5e7b311f60d5d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.874/agentshield_0.2.874_linux_arm64.tar.gz"
      sha256 "a6f4c1cb6793012e6dbd3a2507996aefd8409128646e668b355901b5c657c2f2"
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
