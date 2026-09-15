cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2154"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2154/agentshield_0.2.2154_darwin_amd64.tar.gz"
      sha256 "ad8990b98bc2353a5350c15dfe0af1f5638724cf97a8a4664e0229efea353ec3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2154/agentshield_0.2.2154_darwin_arm64.tar.gz"
      sha256 "c934de0be537b9b09fa2f2dfeda2bb3d7ff0952f3d6ea274d4dd179f994c86c9"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2154/agentshield_0.2.2154_linux_amd64.tar.gz"
      sha256 "f701a348c961903c0d908ac3f77889cab35983c19ba7ea840a5f8184c0708ad4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2154/agentshield_0.2.2154_linux_arm64.tar.gz"
      sha256 "90dbfbdd65e271258237dfbadcacfd8c153db658fd489988cfc41b72a8100697"
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
