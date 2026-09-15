cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2155"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2155/agentshield_0.2.2155_darwin_amd64.tar.gz"
      sha256 "636841df3d180a2179163caf20c1d3ff9278b96b0a6681eae523e858cc934095"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2155/agentshield_0.2.2155_darwin_arm64.tar.gz"
      sha256 "979696732824f4b6a1249d7f3b517bddad2b19be5ef8d84f78f9027748334387"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2155/agentshield_0.2.2155_linux_amd64.tar.gz"
      sha256 "3db863b38e9f2559d9792ede353be9e6d28c3f38584bdb9da5527422607f36c0"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2155/agentshield_0.2.2155_linux_arm64.tar.gz"
      sha256 "f820928f325dfe20739ee215a3e6a9e8d361a907518ca6c452e3adde47d33c26"
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
