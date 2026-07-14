cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1640"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1640/agentshield_0.2.1640_darwin_amd64.tar.gz"
      sha256 "b65f8f85c9078677b930768abafd8fdfbcf8cbd7579b7847d851f754e77a2b08"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1640/agentshield_0.2.1640_darwin_arm64.tar.gz"
      sha256 "edffe1edc937e5bbd81f53466bf016eab63bb7fd6ec585a1fae88ebdaa71e09a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1640/agentshield_0.2.1640_linux_amd64.tar.gz"
      sha256 "b5d88d25646e19ddfbff8d5dd41d8e708b9a1d6786cd28cfcbfd07a5c9076633"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1640/agentshield_0.2.1640_linux_arm64.tar.gz"
      sha256 "1b16b47d096fe63efdfc5082c44b6797b50ab8b50da19caeac66ec77869d98ab"
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
