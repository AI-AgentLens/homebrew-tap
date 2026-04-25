cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.727"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.727/agentshield_0.2.727_darwin_amd64.tar.gz"
      sha256 "3f367bb6305ea84bdca70bec725fac50a21a33dbcbf787e0e2e1a2ba011ddc49"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.727/agentshield_0.2.727_darwin_arm64.tar.gz"
      sha256 "1edd0ef932aa5b9219eb0bb104d1acc1777d8a7c525549032a9da021338f34b6"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.727/agentshield_0.2.727_linux_amd64.tar.gz"
      sha256 "7c9fd83e7528e38a3fb32389ba21d27b6209cc6efd15b3d1eed98d6bfdd6150e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.727/agentshield_0.2.727_linux_arm64.tar.gz"
      sha256 "4f7c1e40de18e5fbef6e7f15342cf591d08a2530f46579b3e769dc0a0d030f09"
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
