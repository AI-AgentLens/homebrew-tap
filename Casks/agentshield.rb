cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.315"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.315/agentshield_0.2.315_darwin_amd64.tar.gz"
      sha256 "798e36c9c9e266206fcd237afb3f527094e573316d6160bd39b40de5bf349906"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.315/agentshield_0.2.315_darwin_arm64.tar.gz"
      sha256 "8709241228e574bc10e7a16b14819fd5b51111e8bfcd3dc9019c9ffbd49c8097"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.315/agentshield_0.2.315_linux_amd64.tar.gz"
      sha256 "836c1c3f13eb7c3291964a5b1e7a39cc40ec81f35d1a0ef0a6953a74411c3d25"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.315/agentshield_0.2.315_linux_arm64.tar.gz"
      sha256 "55568af275d9c513b41a211c4917d0cb82b97c868b2eec8dc5cdfd0f5c93405a"
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
