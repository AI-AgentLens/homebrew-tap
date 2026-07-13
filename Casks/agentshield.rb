cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1638"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1638/agentshield_0.2.1638_darwin_amd64.tar.gz"
      sha256 "99c2835fdf162b165b4af4a222f71b3cba281307400e0f8c40756d2e62f346de"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1638/agentshield_0.2.1638_darwin_arm64.tar.gz"
      sha256 "94ed813b17ea73ce741d0da2a3c7c33998040624df7ef42309ea76be1a8da5cf"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1638/agentshield_0.2.1638_linux_amd64.tar.gz"
      sha256 "5421a99c24d5df0645dfd0b056d2b9b8809ff7c6134f8452293dc7d1a789abc3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1638/agentshield_0.2.1638_linux_arm64.tar.gz"
      sha256 "9ca8fd5fea9d5960f10b2bed2ed9d39c9aaa13e341dbca7ca4e94a1ac738c2b6"
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
